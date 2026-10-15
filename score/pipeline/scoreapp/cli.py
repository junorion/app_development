"""명령줄: 오디오 파일 → MIDI (+ MusicXML 악보)

    python -m scoreapp.cli 입력.mp3 출력.mid --mode piano --musicxml 출력.musicxml
"""

from __future__ import annotations

import argparse
import sys
import time

from . import audio as audio_mod
from .notes import to_midi

MODES = ("piano", "poly", "mono")


def transcriber(mode: str):
    """(채보 함수, 샘플레이트)"""
    if mode == "mono":
        from . import mono
        return mono.transcribe, mono.SR
    from . import models
    if mode == "piano":
        return models.transcribe_piano, models.PIANO_SR
    return models.transcribe_poly, models.POLY_SR


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="scoreapp", description="오디오 파일 → MIDI / MusicXML")
    ap.add_argument("input")
    ap.add_argument("output", help="MIDI 경로")
    ap.add_argument("--mode", choices=MODES, default="mono",
                    help="piano: 피아노 전용 모델 · poly: 악기 무관 다성 · mono: 단선율")
    ap.add_argument("--musicxml", help="악보(MusicXML)도 만든다")
    ap.add_argument("--title", default="Untitled")
    ap.add_argument("--transpose", type=int, default=0, help="반음 단위 조옮김 (악보에만)")
    args = ap.parse_args(argv)

    t0 = time.perf_counter()
    fn, sr = transcriber(args.mode)
    try:
        a = audio_mod.normalize(audio_mod.load(args.input, sr))
    except audio_mod.AudioError as e:
        print(f"오류: {e}", file=sys.stderr)
        return 2
    notes = fn(a)
    to_midi(notes, args.output)
    msg = f"{a.seconds:.1f}초 오디오 → 음표 {len(notes)}개"

    if args.musicxml:
        from .notation import Options, build, write_musicxml
        from .quantize import meter_from_grid, quantize, track_beats

        grid = track_beats(a, notes)
        qs = quantize(notes, grid)
        m = meter_from_grid(grid, notes)
        opts = Options(kind="piano" if args.mode == "piano" else "single", title=args.title, bpm=grid.tempo,
                       beats_per_bar=m[0] if m else None, downbeat_phase=m[1] if m else 0,
                       transpose=args.transpose)
        write_musicxml(build(qs, opts), args.musicxml)
        msg += f", 악보 {grid.tempo:.0f} BPM {m[0] if m else '?'}박자"
    print(f"{msg}, {time.perf_counter() - t0:.1f}초 걸림")
    return 0


if __name__ == "__main__":
    sys.exit(main())
