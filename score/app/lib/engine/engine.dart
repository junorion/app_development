import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'basic_pitch.dart' as bp;
import 'notes.dart';

/// 기기 안 채보 엔진 — 디코드(네이티브) → 정규화 → 창 나누기 → 모델(네이티브) → 음표(Dart).
class TranscriptionEngine {
  TranscriptionEngine({MethodChannel? channel, EventChannel? progress})
      : _ch = channel ?? const MethodChannel('score/engine'),
        _progress = progress ?? const EventChannel('score/progress');

  final MethodChannel _ch;
  final EventChannel _progress;

  static const maxSeconds = 15 * 60.0;

  /// [onProgress] 는 0..1. 디코드가 앞 10%, 모델이 나머지.
  Future<TranscriptionResult> transcribe(String path, {bp.NoteParams params = const bp.NoteParams(), void Function(double)? onProgress}) async {
    onProgress?.call(0);
    final Float32List raw;
    try {
      raw = await _ch.invokeMethod<Float32List>('decode', {'path': path, 'rate': bp.sampleRate, 'maxSeconds': maxSeconds}) ?? Float32List(0);
    } on PlatformException catch (e) {
      throw EngineException(e.message ?? '오디오를 읽을 수 없습니다');
    }
    final audio = normalize(raw);
    final seconds = audio.length / bp.sampleRate;
    if (seconds < 1) throw const EngineException('너무 짧습니다 (1초 이상)');
    onProgress?.call(0.1);

    final wins = bp.windows(audio);
    final sub = _progress.receiveBroadcastStream().listen((d) => onProgress?.call(0.1 + 0.85 * (d as int) / wins.length));
    final Map out;
    try {
      out = await _ch.invokeMethod<Map>('transcribe', {'windows': wins}) ?? {};
    } on PlatformException catch (e) {
      throw EngineException('채보에 실패했습니다: ${e.message}');
    } finally {
      await sub.cancel();
    }
    final note = _split(out['note'] as Float32List, wins.length);
    final onset = _split(out['onset'] as Float32List, wins.length);
    final frames = bp.unwrap(note, audio.length);
    final onsets = bp.unwrap(onset, audio.length);
    final events = bp.outputToNotes(frames, onsets, params);
    onProgress?.call(1);
    return TranscriptionResult(
      seconds: seconds,
      notes: notesFromFrames(events),
      onsetStrength: onsetEnvelope(onsets),
    );
  }

  static List<Float32List> _split(Float32List flat, int n) {
    const per = bp.annotNFrames * bp.nPitches;
    return [for (var i = 0; i < n; i++) Float32List.sublistView(flat, i * per, (i + 1) * per)];
  }
}

class TranscriptionResult {
  const TranscriptionResult({required this.seconds, required this.notes, required this.onsetStrength});
  final double seconds;
  final List<Note> notes;

  /// 프레임별 onset 세기 (모든 음의 onset 활성도 합) — 박 추적에 쓴다. 프레임 시각은 bp.frameToTime.
  final Float32List onsetStrength;
}

class EngineException implements Exception {
  const EngineException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// 직류 제거 후 RMS 를 −20dBFS 로 맞추고 피크를 0.98 이하로 (Python 쪽의 LUFS 정규화를 단순화).
Float32List normalize(Float32List x) {
  if (x.isEmpty) return x;
  var mean = 0.0;
  for (final v in x) {
    mean += v;
  }
  mean /= x.length;
  var sq = 0.0, peak = 0.0;
  for (final v in x) {
    final d = v - mean;
    sq += d * d;
    peak = math.max(peak, d.abs());
  }
  if (peak < 1e-6) throw const EngineException('소리가 없습니다 (무음)');
  final rms = math.sqrt(sq / x.length);
  var gain = 0.1 / rms; // −20 dBFS
  if (peak * gain > 0.98) gain = 0.98 / peak;
  return Float32List.fromList([for (final v in x) (v - mean) * gain]);
}

List<Note> notesFromFrames(List<bp.FrameNote> events) {
  final out = [
    for (final e in events)
      Note(bp.frameToTime(e.start), bp.frameToTime(e.end), e.pitch, (e.amplitude * 127).round().clamp(1, 127)),
  ]..sort((a, b) => a.onset != b.onset ? a.onset.compareTo(b.onset) : a.pitch.compareTo(b.pitch));
  return out;
}

Float32List onsetEnvelope(bp.ActivationMatrix onsets) {
  final env = Float32List(onsets.nFrames);
  for (var t = 0; t < onsets.nFrames; t++) {
    var s = 0.0;
    for (var f = 0; f < bp.nPitches; f++) {
      s += onsets.at(t, f);
    }
    env[t] = s;
  }
  return env;
}
