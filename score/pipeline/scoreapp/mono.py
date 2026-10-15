"""단선율 채보 기준선 — pYIN 음고 추적 + 음 구간 나누기.

모델 없이 돌아가는 기준선이다. 기획 2장의 "단선율 악기" 선택지에 쓰이고, R-3 의 모델들과
비교할 바닥 점수가 된다. 화음은 다루지 못한다.
"""

from __future__ import annotations

import librosa
import numpy as np

from .audio import Audio
from .notes import Note

SR = 22050
HOP = 256  # 약 11.6ms
MIN_NOTE_SEC = 0.06
REATTACK_RATIO = 1.6  # 다시 친 음으로 볼 에너지 상승 배율
BACKTRACK_FRAMES = 6  # 약 70ms
GHOST_RATIO = 0.15  # 음표 평균 에너지의 이 비율보다 작으면 잔향·잡음으로 본다


def transcribe(audio: Audio, fmin: str = "C2", fmax: str = "C7") -> list[Note]:
    assert audio.sr == SR, f"mono.transcribe 는 {SR}Hz 입력을 받는다"
    y = audio.samples
    f0, voiced, _ = librosa.pyin(y, sr=SR, hop_length=HOP, frame_length=2048,
                                 fmin=librosa.note_to_hz(fmin), fmax=librosa.note_to_hz(fmax))
    midi = np.where(voiced, np.round(librosa.hz_to_midi(np.nan_to_num(f0, nan=1.0))), -1).astype(int)
    rms = librosa.feature.rms(y=y, frame_length=2048, hop_length=HOP)[0]
    rms = np.pad(rms, (0, max(0, len(midi) - len(rms))), mode="edge")[: len(midi)]
    onsets = librosa.onset.onset_detect(y=y, sr=SR, hop_length=HOP, backtrack=True)

    def reattack(i: int) -> bool:
        """i 에서 에너지가 다시 솟는가 — 같은 음을 다시 친 것과 잡음이 만든 가짜 onset 을 가른다."""
        before = rms[max(0, i - 4) : i]
        after = rms[i : i + 4]
        return len(before) > 0 and len(after) > 0 and after.max() > REATTACK_RATIO * before.min()

    # 같은 음을 다시 친 곳에서만 끊는다 (음고 변화가 없으니 pYIN 만으로는 모른다)
    splits = {int(i) for i in onsets if reattack(int(i))}

    frame_t = HOP / SR
    raw: list[tuple[int, int, int]] = []
    start, cur = None, -1
    for i, m in enumerate(list(midi) + [-1]):
        if m != cur or (m != -1 and i in splits and start is not None and i - start > 2):
            if cur != -1 and start is not None:
                raw.append((start, i, int(cur)))
            start, cur = i, m

    # pYIN 의 유성 판정은 소리 시작보다 몇 프레임 늦다 — 바로 앞의 onset 으로 당긴다
    onset_list = sorted(int(i) for i in onsets)
    notes: list[Note] = []
    levels = [float(rms[a:b].mean()) for a, b, _ in raw]
    floor = GHOST_RATIO * float(np.median(levels)) if levels else 0.0
    prev_end = 0
    for (a, b, m), level in zip(raw, levels):
        near = [o for o in onset_list if a - BACKTRACK_FRAMES <= o <= a and o >= prev_end]
        if near:
            a = near[-1]
        if (b - a) * frame_t < MIN_NOTE_SEC or level < floor:
            continue
        vel = int(np.clip(40 + 400 * level, 20, 120))
        notes.append(Note(a * frame_t, b * frame_t, m, vel))
        prev_end = b
    return notes
