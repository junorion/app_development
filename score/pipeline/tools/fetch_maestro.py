"""MAESTRO v3 평가용 부분 세트 받기 (백로그 R-2).

오디오 zip 은 약 100GB 라 통째로 받지 않는다. GCS 가 Range 요청을 받으므로 zip 의 목차만 읽고
필요한 곡만 꺼낸다. 라이선스 CC BY-NC-SA 4.0 — 평가에만 쓰고 커밋하지 않는다(score/data/).

    python tools/fetch_maestro.py ../data/maestro --count 8 --max-seconds 240
"""

from __future__ import annotations

import argparse
import io
import json
import shutil
import urllib.request
import zipfile
from pathlib import Path

BASE = "https://storage.googleapis.com/magentadata/datasets/maestro/v3.0.0/"


class HttpRangeFile(io.RawIOBase):
    """읽는 만큼만 Range 로 받아 오는 읽기 전용 파일 — zipfile 이 seek/read 만 쓴다."""

    def __init__(self, url: str):
        self.url, self.pos = url, 0
        with urllib.request.urlopen(urllib.request.Request(url, method="HEAD")) as r:
            self.size = int(r.headers["Content-Length"])

    def readable(self): return True
    def seekable(self): return True
    def tell(self): return self.pos

    def seek(self, off, whence=io.SEEK_SET):
        self.pos = {io.SEEK_SET: off, io.SEEK_CUR: self.pos + off, io.SEEK_END: self.size + off}[whence]
        return self.pos

    def readinto(self, b):
        if self.pos >= self.size:
            return 0
        end = min(self.pos + len(b), self.size) - 1
        req = urllib.request.Request(self.url, headers={"Range": f"bytes={self.pos}-{end}"})
        with urllib.request.urlopen(req) as r:
            data = r.read()
        b[: len(data)] = data
        self.pos += len(data)
        return len(data)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("out", type=Path)
    ap.add_argument("--count", type=int, default=8)
    ap.add_argument("--max-seconds", type=float, default=240)
    args = ap.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)

    meta_path = args.out / "maestro-v3.0.0.json"
    if not meta_path.exists():
        urllib.request.urlretrieve(BASE + "maestro-v3.0.0.json", meta_path)
    d = json.loads(meta_path.read_text())
    # test 분할에서 짧은 곡부터, 작곡가가 겹치지 않게 고른다 (한 작곡가의 양식에 치우치지 않도록)
    keys = sorted((k for k, v in d["split"].items() if v == "test" and d["duration"][k] <= args.max_seconds),
                  key=lambda k: d["duration"][k])
    picked, composers = [], set()
    for k in keys:
        if d["canonical_composer"][k] not in composers:
            picked.append(k)
            composers.add(d["canonical_composer"][k])
        if len(picked) == args.count:
            break

    zips = {"audio": zipfile.ZipFile(io.BufferedReader(HttpRangeFile(BASE + "maestro-v3.0.0.zip"), 1 << 20)),
            "midi": zipfile.ZipFile(io.BufferedReader(HttpRangeFile(BASE + "maestro-v3.0.0-midi.zip"), 1 << 20))}
    index = []
    for k in picked:
        item = {"id": f"maestro_{int(k):04d}", "composer": d["canonical_composer"][k],
                "title": d["canonical_title"][k], "seconds": round(d["duration"][k], 1)}
        for kind, field, ext in (("audio", "audio_filename", ".wav"), ("midi", "midi_filename", ".midi")):
            dst = args.out / (item["id"] + ext)
            if not dst.exists():
                with zips[kind].open("maestro-v3.0.0/" + d[field][k]) as src, open(dst, "wb") as f:
                    shutil.copyfileobj(src, f, 1 << 20)
            item[kind] = dst.name
        index.append(item)
        print(f"{item['id']}  {item['seconds']:6.1f}s  {item['composer']} — {item['title']}")
    (args.out / "index.json").write_text(json.dumps(index, ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main()
