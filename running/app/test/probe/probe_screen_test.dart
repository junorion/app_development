import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:running/app/theme.dart';
import 'package:running/data/db.dart';
import 'package:running/data/run_repository.dart';
import 'package:running/probe/probe_controller.dart';
import 'package:running/probe/probe_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final m = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    m.setMockMethodCallHandler(const MethodChannel('running/platform'), (call) async {
      switch (call.method) {
        case 'deviceInfo':
          return {'manufacturer': 'samsung', 'model': 'SM-A536N', 'release': '14', 'sdk': 34,
            'hasGps': true, 'hasStepCounter': false, 'hasStepDetector': false};
        case 'powerState':
          return {'ignoringBatteryOptimizations': false, 'powerSave': false};
        case 'metronomeStats':
          return {'running': true, 'ticks': 1234, 'underruns': 0, 'seconds': 435.5,
            'maxClockDevMs': 1.2, 'spm': 170.0};
      }
      return null;
    });
    // permission_handler: 모두 "거부" 상태로
    m.setMockMethodCallHandler(const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (call) async => call.method == 'checkPermissionStatus' ? 0 : null);
  });

  for (final size in [const Size(360, 800), const Size(800, 1280)]) {
    for (final theme in [lightTheme, darkTheme]) {
      testWidgets('진단 화면 ${size.width.toInt()}×${size.height.toInt()} ${theme.brightness.name}', (t) async {
        t.view.physicalSize = size;
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final db = AppDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
        final c = ProbeController(RunRepository(db));
        await t.pumpWidget(MaterialApp(theme: theme, home: ProbeScreen(controller: c)));
        await t.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
        await t.pump();
        expect(find.text('SM-A536N', findRichText: true), findsNothing); // 모델은 제조사와 한 줄
        expect(find.textContaining('SM-A536N'), findsOneWidget);
        expect(find.textContaining('걸음 센서가 없어'), findsOneWidget);
        // 아래까지 스크롤해 모든 카드를 그려 본다 — 넘침이 있으면 예외로 실패한다
        await t.drag(find.byType(ListView), const Offset(0, -3000));
        await t.pump();
        expect(find.text('결과와 GPX 보내기'), findsOneWidget);
        expect(t.takeException(), isNull);
        c.dispose();
        await db.close();
        await t.pumpWidget(const SizedBox());
      });
    }
  }
}
