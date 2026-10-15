"""채보 결과의 공통 형식 — 초 단위 음표 목록. 악보(마디·음가)로의 변환은 R-5 에서 한다."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

import pretty_midi


@dataclass(frozen=True)
class Note:
    onset: float   # 초
    offset: float  # 초
    pitch: int     # MIDI 번호 (60 = 가운데 도)
    velocity: int = 80


def to_midi(notes: list[Note], path: str | Path, program: int = 0) -> None:
    pm = pretty_midi.PrettyMIDI()
    inst = pretty_midi.Instrument(program=program)
    for n in notes:
        inst.notes.append(pretty_midi.Note(velocity=n.velocity, pitch=n.pitch, start=n.onset, end=n.offset))
    pm.instruments.append(inst)
    pm.write(str(path))


def from_midi(path: str | Path) -> list[Note]:
    """드럼을 뺀 모든 악기의 음표를 시간순으로."""
    pm = pretty_midi.PrettyMIDI(str(path))
    out = [Note(n.start, n.end, n.pitch, n.velocity)
           for inst in pm.instruments if not inst.is_drum for n in inst.notes]
    return sorted(out, key=lambda n: (n.onset, n.pitch))
