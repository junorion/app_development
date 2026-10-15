"""R-5 양자화·악보 — 직접 만든 곡을 연주하듯 흔들어(템포 흐름 + 타이밍 오차) 되돌릴 수 있는지."""

from fractions import Fraction as F

import numpy as np
import pytest
from music21 import converter

from scoreapp.audio import Audio
from scoreapp.notation import Options, build, detect_key, spell, write_musicxml
from scoreapp.notes import Note
from scoreapp.quantize import Grid, QNote, estimate_meter, quantize, split_hands, track_beats

from synth import render

# 직접 만든 4/4 곡 (박 위치, 길이, 음) — 바장조 느낌, 8분음표·16분음표·점음표를 섞었다
TUNE = [
    (0, 1, 65), (1, 0.5, 67), (1.5, 0.5, 69), (2, 1.5, 70), (3.5, 0.5, 69),
    (4, 1, 67), (5, 1, 65), (6, 2, 72),
    (8, 0.75, 74), (8.75, 0.25, 72), (9, 1, 70), (10, 1, 69), (11, 1, 67),
    (12, 1, 65), (13, 0.5, 64), (13.5, 0.5, 65), (14, 2, 65),
]
BASS = [(b, 4, p) for b, p in ((0, 41), (4, 46), (8, 48), (12, 41))]


def perform(score, bpm=96.0, drift=0.06, jitter=0.012, seed=1):
    """박 → 초. 템포가 사인 꼴로 ±drift 흐르고, 음마다 ±jitter 초 어긋난다."""
    rng = np.random.default_rng(seed)
    beat_len = 60.0 / bpm
    grid = np.linspace(0, 20, 2001)
    speed = 1 + drift * np.sin(grid / 16 * 2 * np.pi)
    t_of = np.concatenate([[0], np.cumsum(np.diff(grid) * beat_len / speed[1:])])
    def t(b):
        return float(np.interp(b, grid, t_of)) + 0.25
    out = []
    for b, length, p in score:
        on = t(b) + rng.normal(0, jitter)
        off = t(b + length) - 0.03 + rng.normal(0, jitter)
        out.append(Note(on, off, p))
    beats = np.array([t(i) for i in range(20)])
    return out, beats


def test_quantize_recovers_rhythm_with_tempo_drift():
    notes, beats = perform(TUNE + BASS)
    qs = quantize(notes, Grid(beats, 96.0))
    got = {(q.beat, q.pitch): q.length for q in qs}
    want = {(F(b).limit_denominator(4), p): F(l).limit_denominator(4) for b, l, p in TUNE + BASS}
    onsets_ok = sum(k in got for k in want) / len(want)
    lengths_ok = sum(got.get(k) == v for k, v in want.items()) / len(want)
    assert onsets_ok == 1.0
    assert lengths_ok >= 0.9


def test_triplets_are_chosen_only_when_they_fit():
    grid = Grid(np.arange(0, 10, 0.5), 120.0)
    trip = [Note(0.5 * (2 + i / 3), 0.5 * (2 + (i + 1) / 3) - 0.01, 60 + i) for i in range(3)]
    straight = [Note(0.5 * (4 + i / 2), 0.5 * (4 + (i + 1) / 2) - 0.01, 64 + i) for i in range(2)]
    qs = quantize(trip + straight, grid)
    assert [q.beat for q in qs] == [0, F(1, 3), F(2, 3), 2, F(5, 2)]


def test_beat_tracking_on_rendered_audio():
    notes, beats = perform(TUNE + BASS, drift=0.0, jitter=0.0)
    a = Audio(render(notes, 22050), 22050)
    g = track_beats(a, notes)
    assert 88 <= g.tempo <= 104 or 176 <= g.tempo <= 208 or 44 <= g.tempo <= 52
    qs = quantize(notes, g)
    # 박 추적이 맞으면 음표들이 정수·반 박에 놓인다
    on_grid = np.mean([q.beat.denominator in (1, 2, 4) for q in qs])
    assert on_grid >= 0.9


def test_meter_three_vs_four():
    four = [QNote(F(b), F(1), 48 if b % 4 == 0 else 67) for b in range(16)]
    four += [QNote(F(b), F(2), 36) for b in range(0, 16, 4)]
    waltz = [QNote(F(b), F(1), 67) for b in range(18)]
    waltz += [QNote(F(b), F(1), 40) for b in range(0, 18, 3)]
    assert estimate_meter(four)[0] == 4
    assert estimate_meter(waltz) == (3, 0)
    shifted = [QNote(q.beat + 1, q.length, q.pitch) for q in waltz]  # 못갖춘마디 1박
    assert estimate_meter(shifted) == (3, 1)


def test_split_hands_follows_wide_chords():
    qs = [QNote(F(0), F(1), p) for p in (36, 43, 48, 64, 67, 72)]  # 넓은 화음 → 큰 간격(48~64)에서 가른다
    qs += [QNote(F(1), F(1), p) for p in (57, 60, 64)]  # 한 손 폭 → 통째로
    r, l = split_hands(qs)
    assert [q.pitch for q in l if q.beat == 0] == [36, 43, 48]
    assert [q.pitch for q in r if q.beat == 1] == [57, 60, 64]


def test_key_and_spelling():
    qs = [QNote(F(i), F(1), p) for i, p in enumerate([65, 67, 69, 70, 72, 74, 76, 77, 72, 65])]
    k = detect_key(qs)
    assert k.tonic.name == "F" and k.mode == "major"
    assert spell(70, k).name == "B-"
    assert spell(66, detect_key([QNote(F(i), F(1), p) for i, p in enumerate([67, 69, 71, 72, 74, 76, 78, 79, 67])])).name == "F#"


@pytest.mark.parametrize("kind", ["piano", "single"])
def test_musicxml_roundtrip(tmp_path, kind):
    qs = [QNote(F(b).limit_denominator(4), F(l).limit_denominator(4), p) for b, l, p in TUNE + BASS]
    sc = build(qs, Options(kind=kind, title="시험곡", bpm=96))
    path = write_musicxml(sc, tmp_path / "t.musicxml")
    back = converter.parse(path)
    assert len(back.parts) == (2 if kind == "piano" else 1)
    for p in back.parts:
        ms = p.getElementsByClass("Measure")
        assert len(ms) == 4
        for m in ms:  # 모든 마디의 길이가 박자표와 맞아야 한다
            assert m.duration.quarterLength == 4
    def tie_of(n, p):
        t = n.getTie(p) if hasattr(n, "getTie") else n.tie
        return t.type if t else None

    pitches = sorted(p.midi for n in back.recurse().notes for p in n.pitches
                     if tie_of(n, p) not in ("stop", "continue"))
    assert sorted(p for _, _, p in TUNE + BASS) == pitches


def test_transpose_moves_key(tmp_path):
    qs = [QNote(F(b).limit_denominator(4), F(l).limit_denominator(4), p) for b, l, p in TUNE]
    sc = build(qs, Options(kind="single", transpose=2))
    ks = sc.recurse().getElementsByClass("KeySignature").first()
    assert ks.sharps == 1  # 바장조(b1) → 사장조(#1)
