"""채점기 (백로그 R-2) — 정답 MIDI 가 붙은 데이터셋에서 채보 방식별 음표 F1·처리 시간을 잰다.

    python -m scoreapp.evaluate ../data/maestro --mode mono --seconds 30

지표는 mir_eval 의 음표 단위 F1 이다 (AMT 논문들과 같은 기준).
- onset F1: 시작 ±50ms, 음고 ±50cent 가 맞으면 정답
- onset+offset F1: 거기에 끝이 길이의 20%(최소 50ms) 안에 들어와야 정답
정답 MIDI 의 끝은 서스테인 페달로 늘린다 — 녹음에서는 페달을 밟는 동안 소리가 이어지기 때문이다.
"""

from __future__ import annotations

import argparse
import json
import resource
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Callable

import mir_eval
import numpy as np
import pretty_midi

from . import audio as audio_mod
from .notes import Note

Transcriber = Callable[[audio_mod.Audio], list[Note]]


@dataclass
class Score:
    onset_p: float
    onset_r: float
    onset_f1: float
    offset_f1: float


def load_reference(path: str | Path, pedal: bool = True) -> list[Note]:
    pm = pretty_midi.PrettyMIDI(str(path))
    out: list[Note] = []
    for inst in pm.instruments:
        if inst.is_drum:
            continue
        ends = _pedal_extended_ends(inst) if pedal else [n.end for n in inst.notes]
        out += [Note(n.start, e, n.pitch, n.velocity) for n, e in zip(inst.notes, ends)]
    return sorted(out, key=lambda n: (n.onset, n.pitch))


def _pedal_extended_ends(inst: pretty_midi.Instrument) -> list[float]:
    """페달이 눌린 동안 떨어진 음은 페달을 뗄 때까지(또는 같은 음을 다시 칠 때까지) 이어진다."""
    downs: list[tuple[float, float]] = []
    on = None
    for cc in sorted((c for c in inst.control_changes if c.number == 64), key=lambda c: c.time):
        if cc.value >= 64 and on is None:
            on = cc.time
        elif cc.value < 64 and on is not None:
            downs.append((on, cc.time))
            on = None
    if on is not None:
        downs.append((on, float("inf")))
    ends = []
    for n in inst.notes:
        e = n.end
        for a, b in downs:
            if a <= n.end < b:
                e = b
                break
        ends.append(e)
    # 같은 음을 다시 치면 앞 음은 거기서 끝난다
    by_pitch: dict[int, list[int]] = {}
    for i, n in enumerate(inst.notes):
        by_pitch.setdefault(n.pitch, []).append(i)
    for idx in by_pitch.values():
        idx.sort(key=lambda i: inst.notes[i].start)
        for a, b in zip(idx, idx[1:]):
            ends[a] = min(ends[a], inst.notes[b].start)
    last = max((n.end for n in inst.notes), default=0.0)
    return [min(e, max(last, n.end) + 10.0) for e, n in zip(ends, inst.notes)]


def crop(notes: list[Note], seconds: float | None) -> list[Note]:
    if seconds is None:
        return notes
    return [Note(n.onset, min(n.offset, seconds), n.pitch, n.velocity) for n in notes if n.onset < seconds]


def score(ref: list[Note], est: list[Note]) -> Score:
    def arr(ns):
        iv = np.array([[n.onset, max(n.offset, n.onset + 1e-3)] for n in ns]).reshape(-1, 2)
        hz = np.array([440.0 * 2 ** ((n.pitch - 69) / 12) for n in ns])
        return iv, hz

    ri, rp = arr(ref)
    ei, ep = arr(est)
    if len(est) == 0:
        return Score(0.0, 0.0, 0.0, 0.0)
    p, r, f, _ = mir_eval.transcription.precision_recall_f1_overlap(ri, rp, ei, ep, offset_ratio=None)
    _, _, f2, _ = mir_eval.transcription.precision_recall_f1_overlap(ri, rp, ei, ep)
    return Score(p, r, f, f2)


def transcriber(mode: str) -> tuple[Transcriber, int]:
    from .cli import MODES, transcriber as pick

    if mode not in MODES:
        raise SystemExit(f"모르는 방식: {mode}")
    return pick(mode)


def run(dataset: Path, mode: str, seconds: float | None, limit: int | None) -> dict:
    fn, sr = transcriber(mode)
    items = json.loads((dataset / "index.json").read_text())[:limit]
    rows = []
    for it in items:
        a = audio_mod.normalize(audio_mod.load(dataset / it["audio"], sr))
        if seconds is not None:
            a = audio_mod.Audio(a.samples[: int(seconds * sr)], sr)
        t0 = time.perf_counter()
        est = fn(a)
        took = time.perf_counter() - t0
        s = score(crop(load_reference(dataset / it["midi"]), seconds), crop(est, seconds))
        rows.append({"id": it["id"], "seconds": round(a.seconds, 1), "took": round(took, 2),
                     "rtf": round(took / a.seconds, 3), "onset_p": round(s.onset_p, 3),
                     "onset_r": round(s.onset_r, 3), "onset_f1": round(s.onset_f1, 3),
                     "offset_f1": round(s.offset_f1, 3)})
        print(f"{it['id']}  onset F1 {s.onset_f1:.3f} (P {s.onset_p:.3f} R {s.onset_r:.3f})  "
              f"onset+offset F1 {s.offset_f1:.3f}  {took:.1f}s", flush=True)
    mean = {k: round(float(np.mean([r[k] for r in rows])), 3) for k in ("onset_f1", "offset_f1", "rtf")}
    peak_mb = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024
    return {"mode": mode, "dataset": dataset.name, "seconds": seconds, "rows": rows,
            "mean": mean, "peak_mb": round(peak_mb)}


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="scoreapp.evaluate")
    ap.add_argument("dataset", type=Path, help="index.json 이 있는 디렉토리")
    ap.add_argument("--mode", default="mono")
    ap.add_argument("--seconds", type=float, default=None, help="곡마다 앞부분 N초만 (빠른 비교용)")
    ap.add_argument("--limit", type=int, default=None)
    ap.add_argument("--json", type=Path, help="결과를 저장할 경로")
    args = ap.parse_args(argv)
    res = run(args.dataset, args.mode, args.seconds, args.limit)
    m = res["mean"]
    print(f"\n[{res['mode']}] 평균 onset F1 {m['onset_f1']:.3f} · onset+offset F1 {m['offset_f1']:.3f} · "
          f"실시간 대비 {m['rtf']:.2f}배 · 최대 메모리 {res['peak_mb']}MB")
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(res, ensure_ascii=False, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())
