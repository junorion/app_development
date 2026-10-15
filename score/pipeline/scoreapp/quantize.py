"""양자화 (백로그 R-5) — 초 단위 음표를 박 단위 음표로 바꾼다.

핵심은 **박 격자에 상대적으로** 양자화하는 것이다. 템포를 하나로 잡고 초를 나누면 연주가 조금만
빨라지거나 느려져도(루바토) 뒤로 갈수록 박이 밀린다. 박 추적으로 실제 박 시각을 얻고, 음표의
시각을 그 박들 사이에서 보간해 "몇 번째 박의 몇 분의 몇" 으로 바꾼다.

한 박 안은 2·4 분할(8분·16분음표)과 3 분할(셋잇단) 중 오차가 작은 쪽으로 맞춘다.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction

import librosa
import numpy as np

from .audio import Audio
from .notes import Note

BINARY = 4   # 한 박을 16분음표로
TRIPLET = 3  # 한 박을 셋잇단 8분음표로
TRIPLET_PENALTY = 1.6  # 셋잇단은 확실히 더 잘 맞을 때만 쓴다 — 아니면 악보가 지저분해진다
MIN_TEMPO, MAX_TEMPO = 50.0, 200.0


@dataclass(frozen=True)
class QNote:
    """박 단위 음표. beat 은 0 부터 세는 박 위치(분수), length 는 박 수(분수)."""
    beat: Fraction
    length: Fraction
    pitch: int
    velocity: int = 80


@dataclass(frozen=True)
class Grid:
    beat_times: np.ndarray  # 초, 단조 증가
    tempo: float            # BPM (중앙값)
    downbeat_times: np.ndarray | None = None  # 마디 첫 박 (beat_this 만 준다)

    def to_beats(self, t: np.ndarray | float) -> np.ndarray:
        """초 → 박(실수). 격자 밖은 처음·마지막 박 간격으로 늘인다."""
        bt = self.beat_times
        t = np.asarray(t, dtype=float)
        idx = np.arange(len(bt), dtype=float)
        first = (bt[1] - bt[0]) if len(bt) > 1 else 60.0 / self.tempo
        last = (bt[-1] - bt[-2]) if len(bt) > 1 else 60.0 / self.tempo
        out = np.interp(t, bt, idx)
        out = np.where(t < bt[0], (t - bt[0]) / first, out)
        out = np.where(t > bt[-1], len(bt) - 1 + (t - bt[-1]) / last, out)
        return out


def track_beats(audio: Audio, notes: list[Note] | None = None, method: str = "beat_this") -> Grid:
    """오디오에서 박을 찾는다.

    beat_this (Foscarin et al. 2024, MIT) 는 박과 강박을 함께 준다. librosa 는 비교용 기준선이다.
    어느 쪽이든 템포가 MIN~MAX 밖으로 잡히면 반·두 배로 접는다.
    """
    if method == "beat_this":
        beats, downs = _beat_this(audio)
        if len(beats) >= 4:
            return _fold(Grid(beats, 60.0 / float(np.median(np.diff(beats))), downs))
    hop = 512
    env = librosa.onset.onset_strength(y=audio.samples, sr=audio.sr, hop_length=hop)
    _, frames = librosa.beat.beat_track(onset_envelope=env, sr=audio.sr, hop_length=hop, trim=False)
    times = librosa.frames_to_time(frames, sr=audio.sr, hop_length=hop)
    if len(times) < 4:  # 박을 못 찾으면 음표 시작들로 템포만 잡아 등간격 격자를 쓴다
        tempo = 100.0
        if notes:
            ons = np.array(sorted({round(n.onset, 2) for n in notes}))
            if len(ons) > 4:
                tempo = float(np.clip(60.0 / np.median(np.diff(ons)), MIN_TEMPO, MAX_TEMPO))
        return Grid(np.arange(0, audio.seconds + 1, 60.0 / tempo), tempo)
    return _fold(Grid(times, 60.0 / float(np.median(np.diff(times)))))


def _fold(g: Grid) -> Grid:
    times, tempo = g.beat_times, g.tempo
    while tempo > MAX_TEMPO and len(times) > 8:  # 너무 빠르면 박을 하나 건너 쓴다
        times, tempo = times[::2], tempo / 2
    if tempo < MIN_TEMPO:  # 너무 느리면 박 사이를 반으로 나눈다
        mids = (times[:-1] + times[1:]) / 2
        times, tempo = np.sort(np.concatenate([times, mids])), tempo * 2
    return Grid(times, tempo, g.downbeat_times)


_BEAT_THIS = None


def _beat_this(audio: Audio) -> tuple[np.ndarray, np.ndarray]:
    global _BEAT_THIS
    if _BEAT_THIS is None:
        import os

        import torch
        from beat_this.inference import Audio2Beats

        torch.set_num_threads(os.cpu_count() or 4)
        _BEAT_THIS = Audio2Beats(checkpoint_path="final0", device="cpu", dbn=False)
    beats, downs = _BEAT_THIS(audio.samples.astype(np.float32), audio.sr)
    return np.asarray(beats, dtype=float), np.asarray(downs, dtype=float)


def meter_from_grid(grid: Grid, notes: list[Note]) -> tuple[int, int] | None:
    """beat_this 강박으로 (한 마디 박 수, 첫 강박 위치). quantize 와 같은 0 박 기준을 쓴다."""
    if grid.downbeat_times is None or len(grid.downbeat_times) < 3 or not notes:
        return None
    db = np.round(grid.to_beats(grid.downbeat_times)).astype(int)
    gaps = np.diff(db)
    gaps = gaps[(gaps >= 2) & (gaps <= 7)]
    if len(gaps) == 0:
        return None
    vals, counts = np.unique(gaps, return_counts=True)
    bpb = int(vals[np.argmax(counts)])
    shift = int(np.floor(grid.to_beats([n.onset for n in notes]).min()))
    phase = int((db[0] - shift) % bpb)
    return bpb, phase


def _snap(x: float, div: int) -> Fraction:
    return Fraction(int(round(x * div)), div)


def quantize(notes: list[Note], grid: Grid) -> list[QNote]:
    if not notes:
        return []
    on = grid.to_beats([n.onset for n in notes])
    off = grid.to_beats([n.offset for n in notes])
    shift = int(np.floor(on.min()))  # 첫 음이 들어 있는 박을 0 박으로
    on, off = on - shift, off - shift

    # 박마다 분할을 고른다: 그 박에서 시작하는 음들의 위치 오차가 작은 쪽
    div_of: dict[int, int] = {}
    for b in set(np.floor(on).astype(int).tolist()):
        fr = on[(on >= b) & (on < b + 1)] - b
        err = {d: float(np.abs(fr * d - np.round(fr * d)).sum()) / d for d in (BINARY, TRIPLET)}
        div_of[b] = TRIPLET if err[TRIPLET] * TRIPLET_PENALTY < err[BINARY] else BINARY

    out = []
    for n, a, z in zip(notes, on, off):
        d = div_of.get(int(np.floor(a)), BINARY)
        start = _snap(a, d)
        dz = div_of.get(int(np.floor(z)), BINARY)
        end = _snap(z, dz)
        if end <= start:
            end = start + Fraction(1, d)
        out.append(QNote(start, end - start, n.pitch, n.velocity))
    return _dedupe(out)


def _dedupe(qs: list[QNote]) -> list[QNote]:
    """양자화로 같은 자리에 겹친 같은 음은 하나로 — 긴 쪽을 남긴다."""
    best: dict[tuple[Fraction, int], QNote] = {}
    for q in qs:
        k = (q.beat, q.pitch)
        if k not in best or q.length > best[k].length:
            best[k] = q
    return sorted(best.values(), key=lambda q: (q.beat, q.pitch))


def estimate_meter(qs: list[QNote]) -> tuple[int, int]:
    """(한 마디 박 수, 첫 강박의 위치) — 3/4 와 4/4 중, 강박에 음이 많이·낮게·길게 몰리는 쪽.

    강박에는 베이스가 오고 긴 음이 놓이는 경향을 쓴다. 판단이 비슷하면 4/4 (대중음악에 압도적으로 많다).
    """
    if not qs:
        return 4, 0
    total = int(max(q.beat + q.length for q in qs)) + 1
    weight = np.zeros(total + 4)
    lo = min(q.pitch for q in qs)
    for q in qs:
        if q.beat.denominator == 1:
            weight[int(q.beat)] += float(q.length) + (1.5 if q.pitch < lo + 12 else 0.0)
    best = (0.0, 4, 0)
    for bpb in (4, 3):
        for phase in range(bpb):
            down = weight[phase::bpb]
            score = float(down.mean() / (weight[:total].mean() + 1e-9))
            if bpb == 4:
                score *= 1.08
            if score > best[0]:
                best = (score, bpb, phase)
    return best[1], best[2]


def split_hands(qs: list[QNote], split: int = 60) -> tuple[list[QNote], list[QNote]]:
    """피아노 양손(높은음자리표 / 낮은음자리표) 나누기.

    같은 순간에 울리는 음 묶음마다, 묶음이 한 손으로 잡히는 폭(옥타브+장3도 이내)이면 묶음의 가운데
    음높이로 통째로 보내고, 넓으면 가장 큰 음정 간격에서 둘로 가른다. 기준점은 직전 묶음들의
    양손 경계를 따라 조금씩 움직인다 — 왼손이 높게 올라가는 곡에서 가운데 도로 고정해 두면
    한 화음이 두 손으로 찢어진다.
    """
    right, left = [], []
    groups: dict[Fraction, list[QNote]] = {}
    for q in qs:
        groups.setdefault(q.beat, []).append(q)
    pivot = float(split)
    for b in sorted(groups):
        g = sorted(groups[b], key=lambda q: q.pitch)
        span = g[-1].pitch - g[0].pitch
        if span <= 16:
            center = (g[0].pitch + g[-1].pitch) / 2
            (right if center >= pivot else left).extend(g)
            continue
        gaps = [(g[i + 1].pitch - g[i].pitch, i) for i in range(len(g) - 1)]
        _, cut = max(gaps)
        left.extend(g[: cut + 1])
        right.extend(g[cut + 1 :])
        mid = (g[cut].pitch + g[cut + 1].pitch) / 2
        pivot = 0.8 * pivot + 0.2 * float(np.clip(mid, 52, 68))
    return sorted(right, key=lambda q: (q.beat, q.pitch)), sorted(left, key=lambda q: (q.beat, q.pitch))
