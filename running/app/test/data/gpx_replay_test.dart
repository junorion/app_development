import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:running/data/gpx.dart';
import 'package:running/features/run/domain/location_sample.dart';
import 'package:running/features/run/domain/noise_filter.dart';
import 'package:running/features/run/domain/run_session.dart';

/// GPX 를 러닝 세션에 1초 단위로 재생한다. 실제 서비스처럼 위치 → tick 순서.
RunSession replay(List<LocationSample> samples) {
  final s = RunSession()
    ..startCountdown()
    ..begin(samples.first.tMs - 1000);
  for (final p in samples) {
    s
      ..onLocation(p)
      ..tick(p.tMs);
  }
  s.finish(samples.last.tMs);
  return s;
}

void main() {
  // 지침 11.2 — 합성 GPX(상관된 GPS 잡음, 튄 점, 터널, 30초 정지)를 재생해 기대값과 비교
  final gpx = File('test/fixtures/loop_3km.gpx').readAsStringSync();
  final expected = jsonDecode(File('test/fixtures/loop_3km.expected.json').readAsStringSync());
  final samples = [for (final (s, _) in parseGpx(gpx)) s];
  final session = replay(samples);

  test('샘플을 모두 읽는다', () {
    expect(samples, hasLength(expected['totalSec']));
    expect(samples.where((s) => s.accuracyM > 25), hasLength(8)); // 터널 8초
  });

  test('거리는 실제 이동 거리의 ±2% 안', () {
    final truth = (expected['trueDistanceM'] as num).toDouble();
    printOnFailure('측정 ${session.distanceM.toStringAsFixed(1)} / 실제 $truth');
    expect(session.distanceM, closeTo(truth, truth * 0.02));
  });

  test('튄 점과 터널 구간은 버려진다', () {
    final r = session.filter.rejected;
    expect(r[RejectReason.tooFast], greaterThanOrEqualTo(2));
    expect(r[RejectReason.inaccurate], 8);
  });

  test('30초 정지는 자동 일시정지로 이동 시간에서 대부분 빠진다', () {
    final moving = session.movingSecAt(samples.last.tMs);
    final truth = expected['trueMovingSec'] as int;
    printOnFailure('이동 시간 $moving / 실제 $truth');
    expect(moving, greaterThan(truth - 5));
    expect(moving, lessThan(truth + 20));
  });

  test('3개의 완성 스플릿과 부분 스플릿', () {
    final all = session.allSplits;
    expect(all.where((s) => !s.isPartial), hasLength(3));
    expect(all.last.isPartial, isTrue);
    for (final s in all.where((s) => !s.isPartial)) {
      // 첫 구간은 2.8m/s 300초 + 3.6m/s 44초 ≈ 344초, 둘째·셋째는 3.2~3.6m/s 라 278~313초
      expect(s.durationSec, inInclusiveRange(270, 350));
    }
  });

  test('GPX 로 내보냈다가 다시 읽으면 같은 점과 구간', () {
    final out = toGpx(session.track, name: '재생 <테스트> & 확인');
    expect(out, contains('재생 &lt;테스트&gt; &amp; 확인'));
    final back = parseGpx(out);
    expect(back, hasLength(session.track.length));
    for (var i = 0; i < back.length; i += 97) {
      expect(back[i].$1.lat, closeTo(session.track[i].sample.lat, 1e-7));
      expect(back[i].$1.tMs, session.track[i].sample.tMs);
    }
  });

  test('일시정지 구간은 trkseg 로 나뉜다', () {
    final s = RunSession()
      ..startCountdown()
      ..begin(0);
    for (var i = 1; i <= 5; i++) {
      s.onLocation(LocationSample(tMs: i * 1000, lat: 37.5 + i * 3e-5, lng: 127, accuracyM: 5));
    }
    s.pause(5000);
    s.resume(60000);
    for (var i = 61; i <= 65; i++) {
      s.onLocation(LocationSample(tMs: i * 1000, lat: 37.6 + i * 3e-5, lng: 127, accuracyM: 5));
    }
    final out = toGpx(s.track, name: 'x');
    expect('<trkseg>'.allMatches(out), hasLength(2));
    expect(parseGpx(out).map((e) => e.$2).toSet(), {0, 1});
  });
}
