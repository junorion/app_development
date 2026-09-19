import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:running/main.dart';

void main() {
  testWidgets('앱이 뜨고 라이트·다크 모두 그려진다', (tester) async {
    await tester.pumpWidget(const RunningApp());
    expect(find.text('0.00'), findsOneWidget);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(find.text('0.00'), findsOneWidget);
    tester.platformDispatcher.clearPlatformBrightnessTestValue();
  });
}
