import 'dart:ui';

/// 0~1 로 편 속도를 5색 스케일(느림 → 빠름) 사이에서 보간한다 (지침 3.2).
/// 스케일은 테마 토큰(`RunTokens.speedScale`)에서 받는다 — 여기서 색을 정하지 않는다.
Color speedColor(List<Color> scale, double t) {
  assert(scale.length >= 2);
  final x = t.clamp(0.0, 1.0) * (scale.length - 1);
  final i = x.floor().clamp(0, scale.length - 2);
  return Color.lerp(scale[i], scale[i + 1], x - i)!;
}
