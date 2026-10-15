import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:score/app/services.dart';
import 'package:score/engine/basic_pitch.dart' show NoteParams;
import 'package:score/engine/engine.dart';
import 'package:score/engine/notes.dart';
import 'package:score/main.dart';
import 'package:score/platform/share.dart';

class FakeEngine extends TranscriptionEngine {
  FakeEngine({this.fail});
  final String? fail;
  @override
  Future<TranscriptionResult> transcribe(String path, {NoteParams params = const NoteParams(), void Function(double)? onProgress}) async {
    onProgress?.call(0.5);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (fail != null) throw EngineException(fail!);
    onProgress?.call(1);
    return TranscriptionResult(seconds: 3, notes: const [Note(0, 0.5, 60), Note(0.5, 1, 64), Note(1, 2, 67)], onsetStrength: Float32List(0));
  }
}

class FakeShare extends ShareInbox {
  FakeShare() : super(channel: const MethodChannel('test/share'));
  String? initial;
  @override
  Future<String?> takeInitial() async {
    final v = initial;
    initial = null;
    return v;
  }

  @override
  Future<String> displayName(String uri) async => '공유된 곡.m4a';
}

void main() {
  testWidgets('파일을 열면 변환 후 결과를 보여 준다', (tester) async {
    final s = Services(engine: FakeEngine(), share: FakeShare(), pickAudio: () async => const PickedAudio('/x/연습곡.mp3', '연습곡.mp3'));
    await tester.pumpWidget(ScoreApp(services: s));
    expect(find.text('음원 파일 열기'), findsOneWidget);
    await tester.tap(find.text('음원 파일 열기'));
    await tester.pumpAndSettle();
    expect(find.text('연습곡'), findsOneWidget);
    expect(find.text('3개'), findsOneWidget);
    expect(find.text('C4 ~ G4'), findsOneWidget);
  });

  testWidgets('공유로 열린 파일은 바로 변환한다', (tester) async {
    final share = FakeShare()..initial = 'content://media/1';
    await tester.pumpWidget(ScoreApp(services: Services(engine: FakeEngine(), share: share)));
    await tester.pumpAndSettle();
    expect(find.text('공유된 곡'), findsOneWidget);
    expect(find.text('3개'), findsOneWidget);
  });

  testWidgets('실패하면 이유와 돌아가기', (tester) async {
    final s = Services(engine: FakeEngine(fail: '오디오 트랙이 없습니다'), share: FakeShare(), pickAudio: () async => const PickedAudio('/x/a.mp4', 'a.mp4'));
    await tester.pumpWidget(ScoreApp(services: s));
    await tester.tap(find.text('음원 파일 열기'));
    await tester.pumpAndSettle();
    expect(find.text('오디오 트랙이 없습니다'), findsOneWidget);
    await tester.tap(find.text('돌아가기'));
    await tester.pumpAndSettle();
    expect(find.text('음원 파일 열기'), findsOneWidget);
  });
}
