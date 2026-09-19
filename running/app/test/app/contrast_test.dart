import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:running/app/theme.dart';
import 'package:running/app/tokens.dart';

/// WCAG 2.x 대비
double contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  for (final p in [RunPalette.light, RunPalette.dark]) {
    group(p.brightness.name, () {
      final bases = {'background': p.background, 'surface': p.surface, 'surfaceVariant': p.surfaceVariant};

      // 지침 3.1 — 본문 4.5:1
      for (final e in bases.entries) {
        test('본문·보조 글자 on ${e.key} ≥ 4.5', () {
          expect(contrast(p.text, e.value), greaterThanOrEqualTo(4.5));
          expect(contrast(p.textSub, e.value), greaterThanOrEqualTo(4.5));
        });
      }

      // 큰 글자·아이콘 3:1 — 바탕 위에 primary·danger 를 전경색으로 쓰는 경우
      test('primary·danger 아이콘 on background ≥ 3', () {
        expect(contrast(p.primary, p.background), greaterThanOrEqualTo(3));
        expect(contrast(p.danger, p.background), greaterThanOrEqualTo(3));
      });

      // 버튼·칩 바탕 위의 글자: onX 는 최소 3(큰 글자), accent 위는 본문도 올라가므로 4.5
      test('on* 대비', () {
        expect(contrast(p.onPrimary, p.primary), greaterThanOrEqualTo(3));
        expect(contrast(p.onDanger, p.danger), greaterThanOrEqualTo(3));
        expect(contrast(p.onAccent, p.accent), greaterThanOrEqualTo(4.5));
      });

      test('순수 검정·흰 바탕을 쓰지 않는다 (지침 3.1)', () {
        expect(p.background, isNot(const Color(0xFF000000)));
        expect(p.background, isNot(const Color(0xFFFFFFFF)));
      });

      test('테마에 토큰이 실려 있다', () {
        final t = buildTheme(p);
        expect(t.extension<RunTokens>()!.speedScale, hasLength(5));
        expect(t.colorScheme.primary, p.primary);
        expect(t.scaffoldBackgroundColor, p.background);
      });
    });
  }

  test('라이트 accent 는 글자색으로 쓸 수 없다 — 그래서 on* 를 둔다', () {
    expect(contrast(RunPalette.light.accent, RunPalette.light.background), lessThan(3));
  });

  test('라이트·다크 테마가 모두 만들어진다', () {
    expect(lightTheme.brightness, Brightness.light);
    expect(darkTheme.brightness, Brightness.dark);
  });
}
