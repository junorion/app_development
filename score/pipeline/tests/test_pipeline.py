import subprocess

import mir_eval
import numpy as np
import pytest
import soundfile as sf

from scoreapp import audio, cli, mono
from scoreapp.notes import from_midi

from synth import melody, render


def note_f1(ref, est, offset=False):
    def arr(ns):
        return (np.array([[n.onset, n.offset] for n in ns]).reshape(-1, 2),
                np.array([440.0 * 2 ** ((n.pitch - 69) / 12) for n in ns]))
        
    ri, rp = arr(ref)
    ei, ep = arr(est)
    p, r, f, _ = mir_eval.transcription.precision_recall_f1_overlap(
        ri, rp, ei, ep, offset_ratio=0.2 if offset else None)
    return f


@pytest.fixture
def wav(tmp_path):
    p = tmp_path / "melody.wav"
    sf.write(p, render(melody(), 44100), 44100)
    return p


def test_load_resamples_to_mono(wav):
    a = audio.load(wav, 22050)
    assert a.sr == 22050 and a.samples.ndim == 1
    assert a.seconds == pytest.approx(8.5, abs=0.1)


@pytest.mark.parametrize("ext", ["mp3", "m4a"])
def test_load_compressed_formats(wav, tmp_path, ext):
    out = tmp_path / f"melody.{ext}"
    subprocess.run([audio.ffmpeg_path(), "-v", "error", "-i", str(wav), str(out)], check=True)
    a = audio.load(out, 22050)
    assert 8.3 < a.seconds < 8.8


def test_normalize_hits_target_and_limits_peak(wav):
    a = audio.normalize(audio.load(wav, 22050))
    import pyloudnorm
    assert pyloudnorm.Meter(22050).integrated_loudness(a.samples.astype(np.float64)) == pytest.approx(audio.TARGET_LUFS, abs=0.5)
    assert np.abs(a.samples).max() <= audio.PEAK_LIMIT + 1e-6


def test_rejects_silence_and_garbage(tmp_path):
    silent = tmp_path / "silent.wav"
    sf.write(silent, np.zeros(44100 * 2, dtype=np.float32), 44100)
    with pytest.raises(audio.AudioError, match="무음"):
        audio.normalize(audio.load(silent, 22050))
    junk = tmp_path / "junk.mp3"
    junk.write_bytes(b"not audio at all" * 100)
    with pytest.raises(audio.AudioError, match="읽을 수 없습니다"):
        audio.load(junk, 22050)


def test_mono_transcribes_clean_melody(wav):
    est = mono.transcribe(audio.normalize(audio.load(wav, mono.SR)))
    assert note_f1(melody(), est) >= 0.9  # onset ±50ms, 음고 ±50cent


def test_mono_survives_noise(tmp_path):
    p = tmp_path / "noisy.wav"
    sf.write(p, render(melody(), 44100, noise_db=-35), 44100)
    est = mono.transcribe(audio.normalize(audio.load(p, mono.SR)))
    assert note_f1(melody(), est) >= 0.8


def test_cli_writes_midi(wav, tmp_path):
    out = tmp_path / "out.mid"
    assert cli.main([str(wav), str(out)]) == 0
    assert len(from_midi(out)) >= 12
