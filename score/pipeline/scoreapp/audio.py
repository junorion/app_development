"""오디오 읽기와 정규화 (기획 1장 — 모델 입력 전 정규화).

어떤 형식이든 ffmpeg 로 디코드해 모노 float32 로 만들고, 라우드니스를 맞춘 뒤 피크를 제한한다.
압축 음원의 손실된 배음은 되살릴 수 없다 — 여기서 하는 일은 모델마다 다른 입력 조건
(샘플레이트·채널·레벨)을 한 곳에서 맞추는 것이다.
"""

from __future__ import annotations

import os
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path

import numpy as np
import pyloudnorm

TARGET_LUFS = -20.0
PEAK_LIMIT = 0.98  # 정규화 뒤 클리핑을 막는 상한 (선형)
MIN_SECONDS = 1.0
MAX_SECONDS = 15 * 60  # 15분 — 서버 처리 시간 상한의 기본값


class AudioError(Exception):
    """사용자에게 보여줄 수 있는 오디오 입력 오류."""


@dataclass(frozen=True)
class Audio:
    samples: np.ndarray  # 모노 float32, -1..1
    sr: int

    @property
    def seconds(self) -> float:
        return len(self.samples) / self.sr


def ffmpeg_path() -> str:
    for cand in (os.environ.get("FFMPEG"), shutil.which("ffmpeg"), str(Path.home() / "toolchain/ffmpeg/ffmpeg")):
        if cand and Path(cand).is_file():
            return cand
    raise AudioError("ffmpeg 를 찾을 수 없습니다 (FFMPEG 환경변수 또는 PATH)")


def load(path: str | Path, sr: int) -> Audio:
    """파일을 sr 로 리샘플한 모노로 읽는다. mp3·m4a·wav·flac·ogg 등 ffmpeg 가 아는 형식 모두."""
    path = Path(path)
    if not path.is_file():
        raise AudioError(f"파일이 없습니다: {path}")
    cmd = [ffmpeg_path(), "-nostdin", "-v", "error", "-i", str(path),
           "-vn", "-ac", "1", "-ar", str(sr), "-f", "f32le", "-"]
    proc = subprocess.run(cmd, capture_output=True)
    if proc.returncode != 0:
        msg = proc.stderr.decode(errors="replace").strip().splitlines()
        raise AudioError("오디오를 읽을 수 없습니다" + (f": {msg[-1]}" if msg else ""))
    samples = np.frombuffer(proc.stdout, dtype=np.float32).copy()
    audio = Audio(samples, sr)
    if audio.seconds < MIN_SECONDS:
        raise AudioError(f"너무 짧습니다 ({audio.seconds:.1f}초)")
    if audio.seconds > MAX_SECONDS:
        raise AudioError(f"너무 깁니다 ({audio.seconds / 60:.0f}분, 최대 {MAX_SECONDS // 60}분)")
    return audio


def normalize(audio: Audio, target_lufs: float = TARGET_LUFS) -> Audio:
    """직류 성분 제거 → 라우드니스 target_lufs → 피크 PEAK_LIMIT 이하."""
    x = audio.samples.astype(np.float64)
    x = x - x.mean()
    peak = np.abs(x).max()
    if peak < 1e-6:
        raise AudioError("소리가 없습니다 (무음)")
    meter = pyloudnorm.Meter(audio.sr)
    loudness = meter.integrated_loudness(x)
    if np.isfinite(loudness):
        x = x * 10 ** ((target_lufs - loudness) / 20)
    else:  # 너무 짧거나 조용해 게이트에 다 걸린 경우 — 피크 기준으로만 맞춘다
        x = x / peak * 0.5
    peak = np.abs(x).max()
    if peak > PEAK_LIMIT:
        x = x * (PEAK_LIMIT / peak)
    return Audio(x.astype(np.float32), audio.sr)
