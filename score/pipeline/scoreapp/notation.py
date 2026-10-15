"""악보 만들기 (백로그 R-5) — 박 단위 음표 → music21 Score → MusicXML.

한 박 = 4분음표로 둔다. 겹치는 음(한 손이 화음을 잡고 다른 음을 이어 치는 경우)은
시간 조각마다 화음으로 묶고 음마다 붙임줄로 잇는다 — 성부를 나누는 것보다 단순하고,
에디터(D-4)에서 고치기 쉽다.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from pathlib import Path

from music21 import chord, clef, instrument, key, layout, meter, note, pitch, stream, tempo, tie

from .quantize import QNote, estimate_meter, split_hands

BLACK_KEYS = {1, 3, 6, 8, 10}


@dataclass(frozen=True)
class Options:
    kind: str = "piano"   # "piano" (큰보표, 양손) | "single" (보표 하나)
    title: str = "Untitled"
    bpm: float | None = None
    beats_per_bar: int | None = None  # None 이면 추정
    downbeat_phase: int = 0           # beats_per_bar 를 줄 때 첫 강박의 박 위치
    transpose: int = 0               # 반음 (R-7 조옮김)


def detect_key(qs: list[QNote]) -> key.Key:
    """Krumhansl–Schmuckler (음 길이로 가중한 음높이 분포와 장·단조 프로필의 상관)."""
    s = stream.Stream()
    for q in qs:
        n = note.Note(q.pitch)
        n.quarterLength = float(q.length)
        s.append(n)
    if not qs:
        return key.Key("C")
    return s.analyze("key")


SHARP_NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
FLAT_NAMES = ["C", "D-", "D", "E-", "E", "F", "G-", "G", "A-", "A", "B-", "B"]


def spell(midi: int, k: key.Key) -> pitch.Pitch:
    """조에 맞는 이름으로 — 플랫 조에서는 검은건반을 플랫으로, 그 밖(샤프 조·다장조)에는 샤프로."""
    names = FLAT_NAMES if k.sharps < 0 else SHARP_NAMES
    return pitch.Pitch(f"{names[midi % 12]}{midi // 12 - 1}")


def _slices(qs: list[QNote], k: key.Key, offset: Fraction) -> list[note.GeneralNote]:
    """겹치는 음을 시간 조각으로 자르고, 붙임줄은 **음마다** 단다.

    music21 chordify 는 붙임줄을 화음 전체에 걸어서, 높이가 다른 음끼리 이어진 것처럼 표기된다.
    """
    if not qs:
        return []
    edges = sorted({q.beat for q in qs} | {q.beat + q.length for q in qs})
    out: list[note.GeneralNote] = []
    for a, b in zip(edges, edges[1:]):
        sounding = [q for q in qs if q.beat <= a < q.beat + q.length]
        dur = b - a
        if not sounding:
            el = note.Rest(quarterLength=dur)
        else:
            el = chord.Chord([spell(q.pitch, k) for q in sounding], quarterLength=dur)
            el.volume.velocity = max(q.velocity for q in sounding)
            for q, pt in zip(sounding, el.pitches):
                starts, ends = q.beat == a, q.beat + q.length == b
                if starts and ends:
                    continue
                t = "start" if starts else ("stop" if ends else "continue")
                el.setTie(tie.Tie(t), pt)
            if len(sounding) == 1:
                one = note.Note(el.pitches[0], quarterLength=dur)
                one.volume.velocity = el.volume.velocity
                one.tie = el.getTie(el.pitches[0])
                el = one
        el.offset = a + offset
        out.append(el)
    return out


def _staff(qs: list[QNote], k: key.Key, offset: Fraction, ts: str, clef_obj, part_cls=stream.Part):
    part = part_cls()
    part.insert(0, clef_obj)
    part.insert(0, key.Key(k.tonic.name, k.mode))
    part.insert(0, meter.TimeSignature(ts))
    if offset:
        part.insert(0, note.Rest(quarterLength=offset))
    for el in _slices(qs, k, offset):
        part.insert(el.offset, el)
    return part


def build(qs: list[QNote], opts: Options = Options()) -> stream.Score:
    if opts.transpose:
        qs = [QNote(q.beat, q.length, q.pitch + opts.transpose, q.velocity) for q in qs]
    if opts.beats_per_bar:
        bpb, phase = opts.beats_per_bar, opts.downbeat_phase % opts.beats_per_bar
    else:
        bpb, phase = estimate_meter(qs)
    ts = f"{bpb}/4"
    # 첫 강박이 마디 첫 박에 오도록 앞을 쉼표로 민다 (못갖춘마디를 갖춘마디로 표기)
    offset = Fraction((bpb - phase) % bpb)
    k = detect_key(qs)

    sc = stream.Score()
    sc.metadata = None
    from music21 import metadata

    sc.metadata = metadata.Metadata(title=opts.title)
    if opts.kind == "piano":
        right, left = split_hands(qs)
        rh = _staff(right, k, offset, ts, clef.TrebleClef(), stream.PartStaff)
        lh = _staff(left, k, offset, ts, clef.BassClef(), stream.PartStaff)
        rh.insert(0, instrument.Piano())
        lh.insert(0, instrument.Piano())
        if opts.bpm:
            rh.insert(0, tempo.MetronomeMark(number=round(opts.bpm)))
        parts = [rh, lh]
    else:
        lo = sorted(q.pitch for q in qs)[len(qs) // 2] if qs else 60
        c = clef.TrebleClef() if lo >= 55 else clef.BassClef()
        p = _staff(qs, k, offset, ts, c)
        if opts.bpm:
            p.insert(0, tempo.MetronomeMark(number=round(opts.bpm)))
        parts = [p]

    end = max((offset + q.beat + q.length for q in qs), default=Fraction(bpb))
    bars = int(-(-end // bpb))  # 올림
    for p in parts:
        p.makeRests(fillGaps=True, inPlace=True, timeRangeFromBarDuration=False)
        last = p.highestTime
        if last < bars * bpb:
            r = note.Rest(quarterLength=bars * bpb - last)
            p.insert(last, r)
        m = p.makeMeasures()
        m.makeTies(inPlace=True)
        m.makeBeams(inPlace=True)
        sc.insert(0, m)
    if opts.kind == "piano":
        sc.insert(0, layout.StaffGroup(list(sc.parts), symbol="brace", barTogether=True))
    return sc


def write_musicxml(sc: stream.Score, path: str | Path) -> Path:
    return Path(sc.write("musicxml", fp=str(path)))
