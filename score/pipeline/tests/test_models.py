"""모델 감싸개 연기 시험 — 가중치가 없으면 건너뛴다 (score/models/ 는 커밋하지 않는다)."""

import pytest
import soundfile as sf

from scoreapp import audio, models
from scoreapp.evaluate import score

from synth import melody, render


@pytest.fixture(scope="module")
def wav(tmp_path_factory):
    p = tmp_path_factory.mktemp("m") / "melody.wav"
    sf.write(p, render(melody(), 44100), 44100)
    return p


def test_poly_on_synth_melody(wav):
    est = models.transcribe_poly(audio.normalize(audio.load(wav, models.POLY_SR)))
    assert score(melody(), est).onset_f1 >= 0.85


@pytest.mark.skipif(not (models.MODELS_DIR / "bytedance_piano_note_pedal.pth").exists(), reason="피아노 가중치 없음")
def test_piano_on_synth_melody(wav):
    est = models.transcribe_piano(audio.normalize(audio.load(wav, models.PIANO_SR)))
    # 피아노 전용 모델이라 합성음(배음 감쇠가 피아노와 다르다)에서는 느슨하게 본다
    assert score(melody(), est).onset_f1 >= 0.6
