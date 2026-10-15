"""R-5 실험 — 박 추적 + 양자화가 실제 음악에서 박 위치를 맞히는가.

채보 오류를 빼고 보기 위해 **정답 음표**를 넣는다. 박 격자만 섞인 음원(mix.wav)에서 추적하고,
정답 MIDI 의 템포 지도에서 나온 진짜 박 위치와 비교한다.
- 박 추적이 반·두 배 템포로 잡힌 경우는 배율 1/2·1·2 중 가장 잘 맞는 것으로 본다 (악보 표기는
  달라지지만 리듬 자체는 맞다 — 표기 배율은 사용자가 고칠 수 있게 한다).
- 시작 박의 차이(정수 박 이동)는 무시한다.

    python tools/eval_rhythm.py ../data/slakh/babyslakh_16k --seconds 60
"""

from __future__ import annotations

import argparse
import sys
from fractions import Fraction
from pathlib import Path

import numpy as np
import pretty_midi

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from scoreapp import audio as audio_mod  # noqa: E402
from scoreapp.evaluate import crop  # noqa: E402
from scoreapp.notes import Note  # noqa: E402
from scoreapp.quantize import quantize, track_beats  # noqa: E402


def true_beats(pm: pretty_midi.PrettyMIDI, notes: list[Note]) -> np.ndarray:
    beats = pm.get_beats()
    idx = np.arange(len(beats), dtype=float)
    on = np.array([n.onset for n in notes])
    return np.interp(on, beats, idx, left=np.nan, right=np.nan)


def accuracy(est: np.ndarray, ref: np.ndarray) -> tuple[float, float]:
    """(맞은 비율, 쓴 배율) — 정수 이동은 가장 많이 맞는 값으로 고른다."""
    best = (0.0, 1.0)
    ok = ~np.isnan(ref)
    for factor in (0.5, 1.0, 2.0):
        r = np.round(ref[ok] * factor * 4) / 4
        e = est[ok]
        diffs = e - r
        vals, counts = np.unique(np.round(diffs, 3), return_counts=True)
        shift = vals[np.argmax(counts)]
        hit = float(np.mean(np.abs(diffs - shift) < 1e-6))
        if hit > best[0]:
            best = (hit, factor)
    return best


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("root", type=Path)
    ap.add_argument("--seconds", type=float, default=60)
    ap.add_argument("--beats", choices=["beat_this", "librosa"], default="beat_this")
    args = ap.parse_args()
    hits = []
    for tr in sorted(p for p in args.root.iterdir() if (p / "all_src.mid").exists()):
        pm = pretty_midi.PrettyMIDI(str(tr / "all_src.mid"))
        notes = crop(sorted((Note(n.start, n.end, n.pitch) for i in pm.instruments if not i.is_drum
                             for n in i.notes), key=lambda n: n.onset), args.seconds)
        a = audio_mod.normalize(audio_mod.load(tr / "mix.wav", 22050))
        a = audio_mod.Audio(a.samples[: int(args.seconds * 22050)], 22050)
        g = track_beats(a, notes, method=args.beats)
        qs = quantize(notes, g)
        # quantize 는 음을 정렬·중복 제거하므로 (시각, 음) 으로 다시 짝짓는다
        shift = int(np.floor(g.to_beats([n.onset for n in notes]).min()))
        est = []
        for n in notes:
            b = g.to_beats(n.onset) - shift
            cands = [q.beat for q in qs if q.pitch == n.pitch and abs(float(q.beat) - b) < 0.5]
            est.append(float(min(cands, key=lambda x: abs(float(x) - b))) if cands else np.nan)
        est = np.array(est)
        ref = true_beats(pm, notes)
        ok = ~np.isnan(est)
        hit, factor = accuracy(est[ok], ref[ok])
        true_bpm = float(pm.get_tempo_changes()[1][0])
        hits.append(hit)
        print(f"{tr.name}  박 위치 정확도 {hit:.3f} (배율 {factor:g})  추정 {g.tempo:5.1f} BPM / 정답 {true_bpm:5.1f}")
    print(f"\n평균 {np.mean(hits):.3f}  ({len(hits)}곡)")


if __name__ == "__main__":
    main()
