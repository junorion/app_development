"""앱(Dart) 이식 시험용 골든 파일 — 직접 만든 다성 곡을 Basic Pitch 로 돌린 모델 출력과 기대 결과.

    python tools/make_app_goldens.py ../app/test/fixtures

저작권 걱정이 없도록 곡은 여기서 직접 정한 음표다. 만드는 파일:
  bp_note.f32, bp_onset.f32  모델 출력 (프레임 × 88, little-endian float32)
  bp_expected.json           Basic Pitch 후처리 결과 (프레임 단위 + 초 단위)
  bp_input.f32               모델 입력 오디오 (22050Hz 모노) — 기기에서 같은 출력이 나오는지 볼 때
"""

from __future__ import annotations

import json
import logging
import sys
from pathlib import Path

import numpy as np

sys.path[:0] = [str(Path(__file__).resolve().parents[1]), str(Path(__file__).resolve().parents[1] / "tests")]
logging.getLogger().setLevel(logging.ERROR)

from basic_pitch import note_creation as nc  # noqa: E402
from basic_pitch.constants import AUDIO_SAMPLE_RATE, FFT_HOP  # noqa: E402

from scoreapp import models  # noqa: E402
from scoreapp.audio import Audio, normalize  # noqa: E402
from scoreapp.notes import Note  # noqa: E402
from synth import render  # noqa: E402


def piece() -> list[Note]:
    """직접 만든 6초짜리 다성 곡 — 위 선율, 가운데 화음, 아래 베이스."""
    beat = 0.5
    out = []
    melody = [(76, 1), (74, 1), (72, 1), (74, 0.5), (76, 0.5), (79, 2), (77, 1), (76, 1), (74, 2)]
    t = 0.0
    for p, b in melody:
        out.append(Note(t, t + b * beat * 0.92, p))
        t += b * beat
    for i, chord in enumerate([(60, 64, 67), (57, 60, 64), (53, 57, 60), (55, 59, 62)]):
        for p in chord:
            out.append(Note(i * 2 * beat * 1.5, i * 2 * beat * 1.5 + 1.4, p))
    for i, p in enumerate([48, 45, 41, 43]):
        out.append(Note(i * 1.5, i * 1.5 + 1.45, p))
    return out


def main() -> None:
    out_dir = Path(sys.argv[1])
    out_dir.mkdir(parents=True, exist_ok=True)
    y = render(piece(), AUDIO_SAMPLE_RATE)
    a = normalize(Audio(y, AUDIO_SAMPLE_RATE))

    # models.transcribe_poly 와 같은 경로로 모델 출력을 얻는다
    from basic_pitch.constants import AUDIO_N_SAMPLES
    from basic_pitch.inference import unwrap_output, window_audio_file

    m = models._poly_model()
    n_olap = 30
    overlap_len = n_olap * FFT_HOP
    hop = AUDIO_N_SAMPLES - overlap_len
    x = np.concatenate([np.zeros(overlap_len // 2, np.float32), a.samples])
    acc = {"note": [], "onset": [], "contour": []}
    for win, _ in window_audio_file(x, hop):
        for k, v in m.predict(np.expand_dims(win, 0)).items():
            acc[k].append(v)
    out = {k: unwrap_output(np.concatenate(v), len(a.samples), n_olap) for k, v in acc.items()}

    params = dict(onset_thresh=0.5, frame_thresh=0.3, min_note_len=int(np.round(58 / 1000 * (AUDIO_SAMPLE_RATE / FFT_HOP))))
    frames_events = nc.output_to_notes_polyphonic(out["note"].copy(), out["onset"].copy(), infer_onsets=True,
                                                  max_freq=None, min_freq=None, melodia_trick=True, **params)
    times = nc.model_frames_to_time(out["note"].shape[0])
    a.samples.astype("<f4").tofile(out_dir / "bp_input.f32")
    out["note"].astype("<f4").tofile(out_dir / "bp_note.f32")
    out["onset"].astype("<f4").tofile(out_dir / "bp_onset.f32")
    exp = {
        "n_frames": int(out["note"].shape[0]),
        "n_samples": int(len(a.samples)),
        "params": params,
        "events": [[int(s), int(e), int(p), float(amp)] for s, e, p, amp in frames_events],
        "times": [float(t) for t in times],
        "reference": [[n.onset, n.offset, n.pitch] for n in piece()],
    }
    (out_dir / "bp_expected.json").write_text(json.dumps(exp))
    print(f"프레임 {exp['n_frames']}, 음표 {len(exp['events'])}개, 입력 {len(a.samples)} 샘플")


if __name__ == "__main__":
    main()
