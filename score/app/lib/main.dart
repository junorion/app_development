import 'package:flutter/material.dart';

import 'app/services.dart';
import 'app/theme.dart';
import 'screens/home.dart';

void main() => runApp(ScoreApp(services: Services()));

class ScoreApp extends StatelessWidget {
  const ScoreApp({super.key, required this.services});
  final Services services;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: '악보 추출',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: HomeScreen(services: services),
      );
}
