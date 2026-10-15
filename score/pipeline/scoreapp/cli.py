"""명령줄: python -m scoreapp.cli <입력 오디오> <출력.mid> [--mode mono]"""

from __future__ import annotations

import argparse
import sys
import time

from . import audio as audio_mod
from . import mono
from .notes import to_midi


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="scoreapp", description="오디오 파일 → MIDI")
    ap.add_argument("input")
    ap.add_argument("output")
    ap.add_argument("--mode", choices=["mono"], default="mono", help="채보 방식 (R-3 에서 피아노·다성 추가)")
    args = ap.parse_args(argv)

    t0 = time.perf_counter()
    try:
        a = audio_mod.normalize(audio_mod.load(args.input, mono.SR))
    except audio_mod.AudioError as e:
        print(f"오류: {e}", file=sys.stderr)
        return 2
    notes = mono.transcribe(a)
    to_midi(notes, args.output)
    print(f"{a.seconds:.1f}초 오디오 → 음표 {len(notes)}개, {time.perf_counter() - t0:.1f}초 걸림")
    return 0


if __name__ == "__main__":
    sys.exit(main())
