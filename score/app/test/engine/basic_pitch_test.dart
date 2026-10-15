import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:score/engine/basic_pitch.dart';

/// tools/make_app_goldens.py 가 만든 골든 — 직접 만든 다성 곡을 Python Basic Pitch 로 돌린 결과.
Float32List _f32(String name) {
  final bytes = File('test/fixtures/$name').readAsBytesSync();
  return bytes.buffer.asFloat32List(bytes.offsetInBytes, bytes.lengthInBytes ~/ 4);
}

void main() {
  final exp = jsonDecode(File('test/fixtures/bp_expected.json').readAsStringSync()) as Map<String, dynamic>;
  final nFrames = exp['n_frames'] as int;
  final note = ActivationMatrix(nFrames, _f32('bp_note.f32'));
  final onset = ActivationMatrix(nFrames, _f32('bp_onset.f32'));

  test('Python 후처리와 같은 음표를 만든다', () {
    final got = outputToNotes(note, onset);
    final want = (exp['events'] as List).cast<List>();
    expect(got.length, want.length);
    for (var i = 0; i < want.length; i++) {
      expect([got[i].start, got[i].end, got[i].pitch], [want[i][0], want[i][1], want[i][2]], reason: '음표 $i');
      expect(got[i].amplitude, closeTo((want[i][3] as num).toDouble(), 1e-4));
    }
  });

  test('프레임 → 초 변환이 원본과 같다', () {
    final times = (exp['times'] as List).cast<num>();
    for (var t = 0; t < times.length; t += 37) {
      expect(frameToTime(t), closeTo(times[t].toDouble(), 1e-9));
    }
  });

  test('창 나누기와 잇기가 프레임 수를 맞춘다', () {
    final n = exp['n_samples'] as int;
    final audio = _f32('bp_input.f32');
    expect(audio.length, n);
    final ws = windows(audio);
    expect(ws.every((w) => w.length == audioNSamples), isTrue);
    // 가짜 모델: 창 번호를 값으로 채운 출력
    final outs = [for (var i = 0; i < ws.length; i++) Float32List(annotNFrames * nPitches)..fillRange(0, annotNFrames * nPitches, i.toDouble())];
    final m = unwrap(outs, n);
    expect(m.nFrames, nFrames);
    expect(m.at(0, 0), 0); // 첫 창
    expect(m.at(annotNFrames - nOverlapFrames, 0), 1); // 두 번째 창의 첫 프레임
  });

  test('음역 제한', () {
    final got = outputToNotes(note, onset, const NoteParams(minPitch: 60, maxPitch: 72));
    expect(got, isNotEmpty);
    expect(got.every((n) => n.pitch >= 60 && n.pitch <= 72), isTrue);
  });

  test('정답 곡과 비교 — 시작이 50ms 안에 맞는 음이 대부분', () {
    final got = outputToNotes(note, onset);
    final ref = (exp['reference'] as List).cast<List>();
    var hit = 0;
    for (final r in ref) {
      if (got.any((g) => g.pitch == r[2] && (frameToTime(g.start) - (r[0] as num)).abs() < 0.05)) hit++;
    }
    expect(hit / ref.length, greaterThan(0.8));
  });
}
