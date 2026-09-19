import 'package:flutter/material.dart';

import 'app/theme.dart';
import 'data/db.dart';
import 'data/run_repository.dart';
import 'probe/probe_controller.dart';
import 'probe/probe_screen.dart';

/// M0 진단 앱 진입점 — `flutter build apk --flavor dev -t lib/main_probe.dart`
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = ProbeController(RunRepository(AppDb()));
  runApp(MaterialApp(
    title: '톡톡런 진단',
    theme: lightTheme,
    darkTheme: darkTheme,
    home: ProbeScreen(controller: controller),
  ));
}
