// Basic Pitch 후처리의 Dart 이식 — 모델 출력(note·onset 활성도) → 음표.
//
// 원본: Spotify basic-pitch 0.4.0 `basic_pitch/note_creation.py`, `inference.py`
// (Copyright Spotify AB, Apache License 2.0). 알고리즘을 그대로 옮기되, melodia 단계의
// "매번 전체 행렬에서 최댓값 찾기"는 값 순서로 한 번 정렬해 차례로 처리하는 방식으로 바꿨다.
// 남은 에너지는 0 으로 지워지기만 하므로 결과가 같다 (동점은 행 우선 순서로 원본과 같게).

import 'dart:math' as math;
import 'dart:typed_data';

const int sampleRate = 22050;
const int fftHop = 256;
const int nPitches = 88;
const int midiOffset = 21;
const int annotationsFps = sampleRate ~/ fftHop; // 86
const int annotNFrames = annotationsFps * 2; // 172 — 창 하나의 출력 프레임 수
const int audioNSamples = sampleRate * 2 - fftHop; // 43844 — 창 하나의 입력 샘플 수
const int nOverlapFrames = 30;
const int overlapLen = nOverlapFrames * fftHop;
const int windowHop = audioNSamples - overlapLen;

/// 프레임 × 88 행렬 (행 우선).
class ActivationMatrix {
  ActivationMatrix(this.nFrames, this.data) : assert(data.length == nFrames * nPitches);
  ActivationMatrix.zeros(this.nFrames) : data = Float32List(nFrames * nPitches);

  final int nFrames;
  final Float32List data;

  double at(int t, int f) => data[t * nPitches + f];
  void set(int t, int f, double v) => data[t * nPitches + f] = v;
  ActivationMatrix copy() => ActivationMatrix(nFrames, Float32List.fromList(data));
}

/// 프레임 단위 음표 (시작 프레임, 끝 프레임(제외), MIDI 음, 세기 0..1)
class FrameNote {
  const FrameNote(this.start, this.end, this.pitch, this.amplitude);
  final int start;
  final int end;
  final int pitch;
  final double amplitude;
}

class NoteParams {
  const NoteParams({
    this.onsetThresh = 0.5,
    this.frameThresh = 0.3,
    this.minNoteLen = 5, // 58ms ≈ 5 프레임 (Python 의 round(58/1000*86.13))
    this.inferOnsets = true,
    this.melodiaTrick = true,
    this.energyTol = 11,
    this.minPitch,
    this.maxPitch,
  });
  final double onsetThresh;
  final double frameThresh;
  final int minNoteLen;
  final bool inferOnsets;
  final bool melodiaTrick;
  final int energyTol;
  final int? minPitch; // MIDI, 포함
  final int? maxPitch; // MIDI, 포함
}

// ---- 창 나누기 / 잇기 (inference.py) ----

/// 모델에 넣을 창들. 앞에 overlapLen/2 만큼 0 을 붙이고 windowHop 간격으로 자른다.
List<Float32List> windows(Float32List audio) {
  final padded = Float32List(audio.length + overlapLen ~/ 2)..setRange(overlapLen ~/ 2, audio.length + overlapLen ~/ 2, audio);
  final out = <Float32List>[];
  for (var i = 0; i < padded.length; i += windowHop) {
    final w = Float32List(audioNSamples);
    final end = math.min(i + audioNSamples, padded.length);
    w.setRange(0, end - i, padded, i);
    out.add(w);
  }
  return out;
}

/// 창별 출력(각 annotNFrames × 88)을 하나로 잇는다 — 겹친 프레임의 앞뒤 절반씩을 버린다.
ActivationMatrix unwrap(List<Float32List> perWindow, int audioLength) {
  const half = nOverlapFrames ~/ 2;
  const keep = annotNFrames - 2 * half;
  final nOriginal = (audioLength * (annotationsFps / sampleRate)).floor();
  final total = math.min(nOriginal, perWindow.length * keep);
  final m = ActivationMatrix.zeros(total);
  var t = 0;
  for (final w in perWindow) {
    for (var r = half; r < annotNFrames - half && t < total; r++, t++) {
      m.data.setRange(t * nPitches, (t + 1) * nPitches, w, r * nPitches);
    }
  }
  return m;
}

/// 프레임 번호 → 초 (note_creation.model_frames_to_time, 원본의 보정값 0.0018 포함)
double frameToTime(int frame) {
  const windowOffset = (fftHop / sampleRate) * (annotNFrames - audioNSamples / fftHop) + 0.0018;
  return frame * fftHop / sampleRate - windowOffset * (frame ~/ annotNFrames);
}

// ---- 음표 만들기 (output_to_notes_polyphonic) ----

ActivationMatrix inferOnsets(ActivationMatrix onsets, ActivationMatrix frames, {int nDiff = 2}) {
  final n = frames.nFrames;
  final diff = ActivationMatrix.zeros(n);
  var maxDiff = 0.0;
  for (var t = nDiff; t < n; t++) {
    for (var f = 0; f < nPitches; f++) {
      var d = double.infinity;
      for (var k = 1; k <= nDiff; k++) {
        final prev = t - k >= 0 ? frames.at(t - k, f) : 0.0;
        d = math.min(d, frames.at(t, f) - prev);
      }
      if (d < 0) d = 0;
      diff.set(t, f, d);
      if (d > maxDiff) maxDiff = d;
    }
  }
  var maxOnset = 0.0;
  for (final v in onsets.data) {
    if (v > maxOnset) maxOnset = v;
  }
  final out = ActivationMatrix.zeros(n);
  for (var i = 0; i < out.data.length; i++) {
    final scaled = maxDiff > 0 ? maxOnset * diff.data[i] / maxDiff : 0.0;
    out.data[i] = math.max(onsets.data[i], scaled);
  }
  return out;
}

List<FrameNote> outputToNotes(ActivationMatrix framesIn, ActivationMatrix onsetsIn, [NoteParams p = const NoteParams()]) {
  final n = framesIn.nFrames;
  final frames = framesIn.copy();
  var onsets = onsetsIn.copy();
  _constrain(frames, onsets, p);
  if (p.inferOnsets) onsets = inferOnsets(onsets, frames);

  // 시간축 극대(양옆보다 엄격히 큼, 양 끝 제외) 이면서 문턱 이상인 onset 들 — 시간 역순, 같은 시각은 음 역순
  final starts = <int>[];
  for (var t = 1; t < n - 1; t++) {
    for (var f = 0; f < nPitches; f++) {
      final v = onsets.at(t, f);
      if (v >= p.onsetThresh && v > onsets.at(t - 1, f) && v > onsets.at(t + 1, f)) starts.add(t * nPitches + f);
    }
  }

  final remaining = frames.copy();
  final notes = <FrameNote>[];
  for (final idx in starts.reversed) {
    final start = idx ~/ nPitches, f = idx % nPitches;
    if (start >= n - 1) continue;
    var i = start + 1, k = 0;
    while (i < n - 1 && k < p.energyTol) {
      k = remaining.at(i, f) < p.frameThresh ? k + 1 : 0;
      i++;
    }
    i -= k;
    if (i - start <= p.minNoteLen) continue;
    for (var t = start; t < i; t++) {
      remaining.set(t, f, 0);
      if (f < nPitches - 1) remaining.set(t, f + 1, 0);
      if (f > 0) remaining.set(t, f - 1, 0);
    }
    notes.add(FrameNote(start, i, f + midiOffset, _mean(frames, start, i, f)));
  }

  if (p.melodiaTrick) {
    // 문턱보다 큰 칸을 값 내림차순(동점은 행 우선 순서)으로 — 원본의 반복 argmax 와 같은 순서
    final cand = <int>[];
    for (var i = 0; i < remaining.data.length; i++) {
      if (remaining.data[i] > p.frameThresh) cand.add(i);
    }
    final vals = Float32List.fromList(remaining.data);
    cand.sort((a, b) {
      final c = vals[b].compareTo(vals[a]);
      return c != 0 ? c : a.compareTo(b);
    });
    for (final idx in cand) {
      if (remaining.data[idx] != vals[idx]) continue; // 앞에서 지워졌다
      final mid = idx ~/ nPitches, f = idx % nPitches;
      remaining.set(mid, f, 0);
      var i = mid + 1, k = 0;
      while (i < n - 1 && k < p.energyTol) {
        k = remaining.at(i, f) < p.frameThresh ? k + 1 : 0;
        _clear3(remaining, i, f);
        i++;
      }
      final end = i - 1 - k;
      i = mid - 1;
      k = 0;
      while (i > 0 && k < p.energyTol) {
        k = remaining.at(i, f) < p.frameThresh ? k + 1 : 0;
        _clear3(remaining, i, f);
        i--;
      }
      final start = i + 1 + k;
      if (end - start <= p.minNoteLen) continue;
      notes.add(FrameNote(start, end, f + midiOffset, _mean(frames, start, end, f)));
    }
  }
  return notes;
}

void _clear3(ActivationMatrix m, int t, int f) {
  m.set(t, f, 0);
  if (f < nPitches - 1) m.set(t, f + 1, 0);
  if (f > 0) m.set(t, f - 1, 0);
}

double _mean(ActivationMatrix m, int a, int b, int f) {
  if (b <= a) return 0;
  var s = 0.0;
  for (var t = a; t < b; t++) {
    s += m.at(t, f);
  }
  return s / (b - a);
}

void _constrain(ActivationMatrix frames, ActivationMatrix onsets, NoteParams p) {
  final lo = p.minPitch == null ? 0 : (p.minPitch! - midiOffset).clamp(0, nPitches);
  final hi = p.maxPitch == null ? nPitches : (p.maxPitch! - midiOffset + 1).clamp(0, nPitches);
  if (lo == 0 && hi == nPitches) return;
  for (var t = 0; t < frames.nFrames; t++) {
    for (var f = 0; f < nPitches; f++) {
      if (f < lo || f >= hi) {
        frames.set(t, f, 0);
        onsets.set(t, f, 0);
      }
    }
  }
}
