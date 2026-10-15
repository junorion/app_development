"""R-4 실험 — 밴드 음악에서 한 악기의 악보를 뽑을 때 음원 분리가 도움이 되는가.

BabySlakh(CC BY 4.0) 각 곡에서 피아노·기타·베이스 스템이 있으면 그 악기의 정답 MIDI 와 비교한다.
  mix     : 섞인 음원을 그대로 채보
  demucs  : Demucs 로 그 악기를 분리한 뒤 채보
  oracle  : 정답 스템(분리가 완벽할 때의 상한)을 채보

    python tools/eval_separation.py ../data/slakh/babyslakh_16k --seconds 60 --json ../out/eval/sep.json
"""

from __future__ import annotations

import argparse
import json
import sys
import time
from pathlib import Path

import numpy as np
import yaml

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from scoreapp import audio as audio_mod  # noqa: E402
from scoreapp import models, separate  # noqa: E402
from scoreapp.evaluate import crop, load_reference, score  # noqa: E402

# Slakh inst_class → (Demucs 스템, 채보 방식)
TARGETS = {"Piano": ("piano", "piano"), "Guitar": ("guitar", "poly"), "Bass": ("bass", "poly")}


def transcribe(mode: str, a: audio_mod.Audio):
    if mode == "piano":
        return models.transcribe_piano(_resample(a, models.PIANO_SR))
    return models.transcribe_poly(_resample(a, models.POLY_SR))


def _resample(a: audio_mod.Audio, sr: int) -> audio_mod.Audio:
    if a.sr == sr:
        return a
    import librosa
    return audio_mod.Audio(librosa.resample(a.samples, orig_sr=a.sr, target_sr=sr).astype(np.float32), sr)


def load(path: Path, seconds: float, sr: int = 44100) -> audio_mod.Audio:
    a = audio_mod.load(path, sr)
    return audio_mod.Audio(a.samples[: int(seconds * sr)], sr)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("root", type=Path)
    ap.add_argument("--seconds", type=float, default=60)
    ap.add_argument("--limit", type=int, default=None)
    ap.add_argument("--json", type=Path)
    args = ap.parse_args()

    rows = []
    tracks = sorted(p for p in args.root.iterdir() if (p / "metadata.yaml").exists())[: args.limit]
    for tr in tracks:
        meta = yaml.safe_load((tr / "metadata.yaml").read_text())
        wanted = {}
        for sid, st in meta["stems"].items():
            cls = st.get("inst_class")
            # BabySlakh 의 audio_rendered/midi_saved 표시는 틀려 있다 — 파일이 있는지로 본다
            has_files = (tr / "stems" / f"{sid}.wav").exists() and (tr / "MIDI" / f"{sid}.mid").exists()
            if cls in TARGETS and has_files and cls not in wanted:
                wanted[cls] = sid
        if not wanted:
            continue
        mix = load(tr / "mix.wav", args.seconds)
        t0 = time.perf_counter()
        stems = separate.separate(audio_mod.normalize(mix))
        sep_took = time.perf_counter() - t0
        for cls, sid in wanted.items():
            stem_name, mode = TARGETS[cls]
            ref = crop(load_reference(tr / "MIDI" / f"{sid}.mid", pedal=False), args.seconds)
            if len(ref) < 10:
                continue
            row = {"track": tr.name, "class": cls, "notes": len(ref), "sep_rtf": round(sep_took / mix.seconds, 3)}
            sources = {"mix": mix, "demucs": stems[stem_name], "oracle": load(tr / "stems" / f"{sid}.wav", args.seconds)}
            for k, a in sources.items():
                try:
                    est = transcribe(mode, audio_mod.normalize(a))
                except audio_mod.AudioError:
                    est = []
                row[k] = round(score(ref, crop(est, args.seconds)).onset_f1, 3)
            rows.append(row)
            print(f"{tr.name} {cls:6s} 정답 {len(ref):4d}음  mix {row['mix']:.3f}  demucs {row['demucs']:.3f}  "
                  f"oracle {row['oracle']:.3f}  (분리 {sep_took:.0f}s)", flush=True)

    print()
    for cls in TARGETS:
        rs = [r for r in rows if r["class"] == cls]
        if rs:
            m = {k: np.mean([r[k] for r in rs]) for k in ("mix", "demucs", "oracle")}
            print(f"{cls:6s} {len(rs)}곡  mix {m['mix']:.3f}  demucs {m['demucs']:.3f}  oracle {m['oracle']:.3f}")
    if rows:
        print(f"분리 처리 시간 / 곡 길이 평균 {np.mean([r['sep_rtf'] for r in rows]):.2f}")
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(rows, ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main()
