import 'package:flutter/material.dart';

/// 색 토큰 (지침 3.1). 위젯은 색을 직접 쓰지 않고 항상 이것을 거친다.
///
/// on* 은 그 색을 **바탕**으로 깔았을 때 위에 올리는 글자·아이콘 색이다. 지침에는 없던 것으로,
/// 대비를 계산해 보고 더했다 (`test/app/contrast_test.dart`):
/// - 라이트 accent 는 크림 바탕에서 1.9:1 이라 글자·아이콘 색으로 쓸 수 없다 — 바탕으로만 쓰고
///   본문색을 얹는다(7.0:1).
/// - 다크의 primary·accent·danger 는 밝아서 흰 글자가 1.6~2.2:1 이다 — 바탕색을 얹는다.
/// - 라이트 primary·danger 위 흰 글자는 3.3~3.4:1 이라 큰 글자(24sp 굵게)와 아이콘에만 쓴다.
@immutable
class RunPalette {
  const RunPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.danger,
    required this.onDanger,
    required this.text,
    required this.textSub,
    required this.speedScale,
    required this.mapVeil,
  });

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color primary;
  final Color onPrimary;
  final Color accent;
  final Color onAccent;
  final Color danger;
  final Color onDanger;
  final Color text;
  final Color textSub;

  /// 느림 → 빠름 5색 (지침 3.2)
  final List<Color> speedScale;

  /// Ready 화면 지도 위에 얹는 반투명 막 (지침 3.5)
  final Color mapVeil;

  static const _speed = [
    Color(0xFF6FB1E8), // 파랑
    Color(0xFF5CC8B0), // 민트
    Color(0xFFF2D16B), // 노랑
    Color(0xFFF2A25E), // 주황
    Color(0xFFE8695F), // 산호
  ];

  static const light = RunPalette(
    brightness: Brightness.light,
    background: Color(0xFFFAF6F0),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF1EBE2),
    primary: Color(0xFF3E9D78),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFF2A65A),
    onAccent: Color(0xFF2E2A26),
    danger: Color(0xFFD9695F),
    onDanger: Color(0xFFFFFFFF),
    text: Color(0xFF2E2A26),
    textSub: Color(0xFF6F6860),
    speedScale: _speed,
    mapVeil: Color(0x9EFAF6F0), // 크림 62%
  );

  static const dark = RunPalette(
    brightness: Brightness.dark,
    background: Color(0xFF1F1C19),
    surface: Color(0xFF2A2622),
    surfaceVariant: Color(0xFF35302B),
    primary: Color(0xFF7CCFAA),
    onPrimary: Color(0xFF1F1C19),
    accent: Color(0xFFF4B778),
    onAccent: Color(0xFF1F1C19),
    danger: Color(0xFFF09A90),
    onDanger: Color(0xFF1F1C19),
    text: Color(0xFFF3EEE7),
    textSub: Color(0xFFB8B0A6),
    speedScale: _speed,
    mapVeil: Color(0x9E1F1C19),
  );
}

/// 간격 (지침 3.3 — 4dp 격자)
abstract final class Gap {
  static const double xs = 4, s = 8, m = 12, l = 16, xl = 24, xxl = 32;
}

/// 색 말고도 테마를 따라가야 하는 값 (지침 3.7)
@immutable
class RunTokens extends ThemeExtension<RunTokens> {
  const RunTokens({
    required this.palette,
    required this.cardRadius,
    required this.sheetRadius,
    required this.softShadow,
  });

  factory RunTokens.of(RunPalette p) => RunTokens(
        palette: p,
        cardRadius: 24,
        sheetRadius: 28,
        // blur 24, 8% (지침 3.3). 다크에서는 그림자가 보이지 않으므로 조금 짙게 둔다.
        softShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: p.brightness == Brightness.dark ? 0.24 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  final RunPalette palette;
  final double cardRadius;
  final double sheetRadius;
  final List<BoxShadow> softShadow;

  List<Color> get speedScale => palette.speedScale;

  @override
  RunTokens copyWith({
    RunPalette? palette,
    double? cardRadius,
    double? sheetRadius,
    List<BoxShadow>? softShadow,
  }) =>
      RunTokens(
        palette: palette ?? this.palette,
        cardRadius: cardRadius ?? this.cardRadius,
        sheetRadius: sheetRadius ?? this.sheetRadius,
        softShadow: softShadow ?? this.softShadow,
      );

  // 팔레트는 테마 전환 애니메이션 중 절반에서 갈아 끼운다. 색 자체의 보간은 ColorScheme 이 한다.
  @override
  RunTokens lerp(ThemeExtension<RunTokens>? other, double t) {
    if (other is! RunTokens) return this;
    return RunTokens(
      palette: t < 0.5 ? palette : other.palette,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t),
      sheetRadius: lerpDouble(sheetRadius, other.sheetRadius, t),
      softShadow: BoxShadow.lerpList(softShadow, other.softShadow, t) ?? other.softShadow,
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

extension RunTokensX on BuildContext {
  RunTokens get tokens => Theme.of(this).extension<RunTokens>()!;
  RunPalette get palette => tokens.palette;
}
