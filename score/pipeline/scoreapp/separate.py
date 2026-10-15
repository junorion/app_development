"""음원 분리 (백로그 R-4) — Demucs v4 6스템(htdemucs_6s): drums, bass, other, vocals, guitar, piano.

가중치는 처음 쓸 때 받아 torch 캐시(~/.cache/torch/hub)에 둔다.
"""

from __future__ import annotations

import os
from functools import lru_cache

import numpy as np

from .audio import Audio

MODEL = "htdemucs_6s"
STEMS = ("drums", "bass", "other", "vocals", "guitar", "piano")


@lru_cache(maxsize=1)
def _model():
    import torch
    from demucs.pretrained import get_model

    torch.set_num_threads(os.cpu_count() or 4)
    m = get_model(MODEL)
    m.eval()
    return m


def separate(audio: Audio) -> dict[str, Audio]:
    """모노 입력을 받아 스템별 모노 Audio 를 돌려준다. 입력 sr 은 무엇이든 되고 결과도 같은 sr 이다."""
    import julius
    import torch
    from demucs.apply import apply_model

    m = _model()
    x = torch.from_numpy(audio.samples.astype(np.float32))[None]
    if audio.sr != m.samplerate:
        x = julius.resample_frac(x, audio.sr, m.samplerate)
    x = x.repeat(m.audio_channels, 1)  # 모델은 스테레오를 받는다
    ref = x.mean(0)
    mean, std = ref.mean(), ref.std() + 1e-8
    with torch.no_grad():
        out = apply_model(m, ((x - mean) / std)[None], shifts=0, split=True, overlap=0.25, progress=False)[0]
    out = out * std + mean
    res = {}
    for name, y in zip(m.sources, out):
        y = y.mean(0)
        if audio.sr != m.samplerate:
            y = julius.resample_frac(y[None], m.samplerate, audio.sr)[0]
        res[name] = Audio(y[: len(audio.samples)].numpy().astype(np.float32), audio.sr)
    return res
