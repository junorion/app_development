"""채보 모델 감싸개 (백로그 R-3). 모두 정규화된 Audio 를 받아 list[Note] 를 돌려준다.

- piano: ByteDance piano_transcription (Kong et al. 2021, PyTorch, 피아노 전용, 페달 포함).
  가중치 172MB 는 score/models/ 에 둔다 (커밋하지 않음).
- poly: Spotify Basic Pitch (ICASSP 2022, 악기 무관 다성). ONNX 모델 230KB 라 기기 안 실행 후보.
"""

from __future__ import annotations

import contextlib
import io
import logging
import os
import tempfile
from functools import lru_cache
from pathlib import Path

import numpy as np

from .audio import Audio
from .notes import Note

MODELS_DIR = Path(os.environ.get("SCORE_MODELS", Path(__file__).resolve().parents[2] / "models"))

PIANO_SR = 16000
POLY_SR = 22050


@lru_cache(maxsize=1)
def _piano_model():
    import torch
    from piano_transcription_inference import PianoTranscription

    torch.set_num_threads(os.cpu_count() or 4)
    return PianoTranscription(device="cpu", checkpoint_path=str(MODELS_DIR / "bytedance_piano_note_pedal.pth"))


def transcribe_piano(audio: Audio) -> list[Note]:
    assert audio.sr == PIANO_SR
    model = _piano_model()
    with tempfile.TemporaryDirectory() as d, contextlib.redirect_stdout(io.StringIO()):  # 진행 출력 숨김
        res = model.transcribe(audio.samples.astype(np.float32), os.path.join(d, "o.mid"))
    return sorted((Note(float(e["onset_time"]), float(e["offset_time"]), int(e["midi_note"]), int(e["velocity"]))
                   for e in res["est_note_events"]), key=lambda n: (n.onset, n.pitch))


@lru_cache(maxsize=1)
def _poly_model():
    logging.getLogger().setLevel(logging.ERROR)  # 설치하지 않은 TF/TFLite 경고를 숨긴다
    from basic_pitch import ICASSP_2022_MODEL_PATH
    from basic_pitch.inference import Model

    return Model(Path(ICASSP_2022_MODEL_PATH).with_suffix(".onnx"))


def transcribe_poly(audio: Audio, onset_threshold: float = 0.5, frame_threshold: float = 0.3,
                    min_note_ms: float = 58) -> list[Note]:
    """basic_pitch.inference.predict 와 같은 처리를 파일 대신 배열로 한다."""
    assert audio.sr == POLY_SR
    from basic_pitch import note_creation as infer
    from basic_pitch.constants import AUDIO_N_SAMPLES, AUDIO_SAMPLE_RATE, FFT_HOP
    from basic_pitch.inference import unwrap_output, window_audio_file

    model = _poly_model()
    n_olap_frames = 30
    overlap_len = n_olap_frames * FFT_HOP
    hop = AUDIO_N_SAMPLES - overlap_len
    x = np.concatenate([np.zeros(overlap_len // 2, np.float32), audio.samples.astype(np.float32)])
    out: dict[str, list] = {"note": [], "onset": [], "contour": []}
    for win, _ in window_audio_file(x, hop):
        for k, v in model.predict(np.expand_dims(win, 0)).items():
            out[k].append(v)
    unwrapped = {k: unwrap_output(np.concatenate(v), len(audio.samples), n_olap_frames) for k, v in out.items()}
    min_len = int(np.round(min_note_ms / 1000 * (AUDIO_SAMPLE_RATE / FFT_HOP)))
    _, events = infer.model_output_to_notes(unwrapped, onset_thresh=onset_threshold, frame_thresh=frame_threshold,
                                            min_note_len=min_len, min_freq=None, max_freq=None,
                                            multiple_pitch_bends=False, melodia_trick=True)
    return sorted((Note(float(s), float(e), int(p), int(np.clip(a * 127, 1, 127))) for s, e, p, a, _ in events),
                  key=lambda n: (n.onset, n.pitch))
