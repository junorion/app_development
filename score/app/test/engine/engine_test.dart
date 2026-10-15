import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:score/engine/basic_pitch.dart' as bp;
import 'package:score/engine/engine.dart';

Float32List _f32(String name) {
  final bytes = File('test/fixtures/$name').readAsBytesSync();
  return bytes.buffer.asFloat32List(bytes.offsetInBytes, bytes.lengthInBytes ~/ 4);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('normalize — 무음은 거부, 피크는 0.98 이하', () {
    expect(() => normalize(Float32List(1000)), throwsA(isA<EngineException>()));
    final y = normalize(Float32List.fromList([for (var i = 0; i < 1000; i++) i.isEven ? 0.001 : -0.001]..[10] = 0.5));
    expect(y.reduce((a, b) => a.abs() > b.abs() ? a : b).abs(), lessThanOrEqualTo(0.98 + 1e-6));
  });

  test('엔진 전체 흐름 — 네이티브를 골든 모델 출력으로 대신해 Python 과 같은 음표', () async {
    const ch = MethodChannel('score/engine');
    final input = _f32('bp_input.f32');
    final note = _f32('bp_note.f32');
    final onset = _f32('bp_onset.f32');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ch, (call) async {
      if (call.method == 'decode') return input;
      // 골든은 이미 이어 붙인 출력이므로, 창 단위로 되돌려 넣어 unwrap 이 원래대로 잇는지까지 본다
      final wins = (call.arguments['windows'] as List).length;
      Float32List rewrap(Float32List m) {
        const half = bp.nOverlapFrames ~/ 2, keep = bp.annotNFrames - 2 * half;
        final out = Float32List(wins * bp.annotNFrames * bp.nPitches);
        for (var w = 0; w < wins; w++) {
          for (var r = 0; r < keep; r++) {
            final t = w * keep + r;
            if (t * bp.nPitches >= m.length) break;
            out.setRange((w * bp.annotNFrames + half + r) * bp.nPitches, (w * bp.annotNFrames + half + r + 1) * bp.nPitches, m, t * bp.nPitches);
          }
        }
        return out;
      }
      return {'note': rewrap(note), 'onset': rewrap(onset)};
    });
    final progress = <double>[];
    final r = await TranscriptionEngine().transcribe('x.mp3', onProgress: progress.add);
    expect(r.notes.length, 48);
    expect(r.seconds, closeTo(input.length / bp.sampleRate, 1e-9));
    expect(progress.first, 0);
    expect(progress.last, 1);
  });
}
