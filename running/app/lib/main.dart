import 'package:flutter/material.dart';

import 'app/theme.dart';
import 'app/tokens.dart';

void main() => runApp(const RunningApp());

class RunningApp extends StatelessWidget {
  const RunningApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: '톡톡런',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system, // 설정에서 바꿀 수 있게 한다 (지침 3.7)
        home: const _Placeholder(),
      );
}

/// 화면(D-3)이 들어오기 전까지의 자리
class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('0.00', style: t.displayLarge),
          Text('km', style: t.bodySmall),
          const SizedBox(height: Gap.xl),
          Text('오늘도 가볍게 시작해 볼까요?', style: t.bodyLarge),
        ]),
      ),
    );
  }
}
