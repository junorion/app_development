/// 이벤트 사이 간격 통계. 화면이 꺼진 동안 위치·걸음이 끊기는지를 이것으로 본다 (지침 12.1 M0).
class GapStats {
  GapStats({this.longGapMs = 5000});

  /// 이보다 긴 간격을 "끊김" 으로 센다
  final int longGapMs;

  int count = 0;
  int? _lastMs;
  int maxGapMs = 0;
  int? maxGapAtMs;
  int longGaps = 0;
  int longGapTotalMs = 0;

  void add(int tMs) {
    final last = _lastMs;
    _lastMs = tMs;
    count++;
    if (last == null) return;
    final gap = tMs - last;
    if (gap > maxGapMs) {
      maxGapMs = gap;
      maxGapAtMs = tMs;
    }
    if (gap > longGapMs) {
      longGaps++;
      longGapTotalMs += gap;
    }
  }

  int? get lastMs => _lastMs;

  String describe() => count < 2
      ? '$count건'
      : '$count건 · 최대 간격 ${(maxGapMs / 1000).toStringAsFixed(1)}초 · '
          '${longGapMs ~/ 1000}초 넘는 끊김 $longGaps번(${(longGapTotalMs / 1000).toStringAsFixed(0)}초)';
}

/// 주기 작업의 예정 시각 대비 오차 (Dart Timer 지터 측정용)
class JitterStats {
  int n = 0;
  double sumAbsMs = 0;
  double maxAbsMs = 0;
  int over10ms = 0;

  void add(double errMs) {
    n++;
    final a = errMs.abs();
    sumAbsMs += a;
    if (a > maxAbsMs) maxAbsMs = a;
    if (a > 10) over10ms++;
  }

  double get meanAbsMs => n == 0 ? 0 : sumAbsMs / n;

  String describe() => n == 0
      ? '측정 없음'
      : '$n회 · 평균 ${meanAbsMs.toStringAsFixed(1)}ms · 최대 ${maxAbsMs.toStringAsFixed(1)}ms · '
          '±10ms 초과 $over10ms회 (${(over10ms * 100 / n).toStringAsFixed(1)}%)';
}
