import 'package:flutter/material.dart';

import 'tokens.dart';

/// 수치는 tabular figures — 숫자가 바뀌어도 폭이 흔들리지 않는다 (지침 3.3)
const tabular = [FontFeature.tabularFigures()];

ThemeData buildTheme(RunPalette p) {
  final scheme = ColorScheme(
    brightness: p.brightness,
    primary: p.primary,
    onPrimary: p.onPrimary,
    secondary: p.accent,
    onSecondary: p.onAccent,
    error: p.danger,
    onError: p.onDanger,
    surface: p.surface,
    onSurface: p.text,
    onSurfaceVariant: p.textSub,
    surfaceContainerHighest: p.surfaceVariant,
    surfaceContainer: p.surfaceVariant,
    outline: p.textSub,
  );

  // 크기는 지침 3.3. 러닝 수치(64sp)는 displayLarge 에 둔다.
  final text = TextTheme(
    displayLarge: TextStyle(fontSize: 64, fontWeight: FontWeight.w700, height: 1.0,
        color: p.text, fontFeatures: tabular),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: p.text),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: p.text),
    bodyLarge: TextStyle(fontSize: 16, color: p.text),
    bodyMedium: TextStyle(fontSize: 16, color: p.text),
    bodySmall: TextStyle(fontSize: 13, color: p.textSub),
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: p.text),
    labelMedium: TextStyle(fontSize: 13, color: p.textSub),
  );

  final tokens = RunTokens.of(p);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.background,
    canvasColor: p.background,
    textTheme: text,
    extensions: [tokens],
    cardTheme: CardThemeData(
      color: p.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.cardRadius)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.sheetRadius))),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.surfaceVariant,
      labelStyle: TextStyle(color: p.text),
      shape: const StadiumBorder(),
      side: BorderSide.none,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(56, 56), // 터치 영역 최소 56dp (지침 4.2)
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(56, 56)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: p.primary,
      inactiveTrackColor: p.surfaceVariant,
      thumbColor: p.primary,
    ),
    dividerTheme: DividerThemeData(color: p.surfaceVariant, thickness: 1),
  );
}

final lightTheme = buildTheme(RunPalette.light);
final darkTheme = buildTheme(RunPalette.dark);
