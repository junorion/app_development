"""시험용 오디오 합성 — 저작권 걱정이 없도록 직접 정한 음표를 배음 있는 소리로 만든다."""

from __future__ import annotations

import numpy as np

from scoreapp.notes import Note


def render(notes: list[Note], sr: int, tail: float = 0.5, noise_db: float | None = None) -> np.ndarray:
    total = max(n.offset for n in notes) + tail
    y = np.zeros(int(total * sr))
    for n in notes:
        f = 440.0 * 2 ** ((n.pitch - 69) / 12)
        t = np.arange(int((n.offset - n.onset) * sr)) / sr
        tone = sum(np.sin(2 * np.pi * f * k * t) / k ** 1.5 for k in range(1, 7))
        env = np.minimum(1, t / 0.01) * np.exp(-t * 1.5)
        rel = np.minimum(1, (t[-1] - t) / 0.02)  # 끝을 부드럽게 — 딸깍 소리 방지
        i = int(n.onset * sr)
        y[i : i + len(t)] += 0.2 * tone * env * rel
    if noise_db is not None:
        rng = np.random.default_rng(0)
        y += rng.normal(0, 10 ** (noise_db / 20), len(y))
    return y.astype(np.float32)


def melody() -> list[Note]:
    """직접 만든 8마디짜리 선율 (120BPM, 같은 음 반복과 도약을 일부러 넣었다)."""
    beat = 0.5
    seq = [  # (MIDI, 박 수)
        (60, 1), (64, 1), (67, 1), (67, 1),
        (69, 0.5), (67, 0.5), (65, 1), (64, 2),
        (62, 1), (62, 1), (71, 1), (72, 1),
        (55, 1.5), (59, 0.5), (60, 2),
    ]
    t, out = 0.0, []
    for p, b in seq:
        out.append(Note(t, t + b * beat * 0.95, p))
        t += b * beat
    return out
