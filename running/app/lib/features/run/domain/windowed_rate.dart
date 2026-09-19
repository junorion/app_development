import 'dart:collection';

/// 누적값(거리 m, 걸음 수)의 최근 [windowMs] 동안의 변화율(단위/초).
///
/// 순간값은 너무 흔들리므로 현재 속도(5~10초)와 현재 케이던스(10~15초)를 이것으로 낸다
/// (지침 5.3, 5.4). 샘플이 오지 않는 동안(정지해서 필터가 점을 버리는 중)에도 같은 누적값을
/// 주기적으로 넣어야 값이 0 으로 내려간다.
class WindowedRate {
  WindowedRate(this.windowMs, {this.minSpanMs = 2000});

  final int windowMs;

  /// 창 안의 시간 폭이 이보다 짧으면 값을 내지 않는다 — 시작 직후 한두 점으로 낸 값은 튄다
  final int minSpanMs;

  final _points = ListQueue<(int, double)>();

  void add(int tMs, double cumulative) {
    if (_points.isNotEmpty && tMs <= _points.last.$1) return;
    _points.addLast((tMs, cumulative));
    // 창 시작 시각 이전의 점은 하나만 남긴다 — 창 경계에서의 값을 보간하는 데 쓴다
    while (_points.length > 2 && _points.elementAt(1).$1 <= tMs - windowMs) {
      _points.removeFirst();
    }
  }

  void clear() => _points.clear();

  /// 단위/초. 값을 낼 수 없으면 null.
  double? get rate {
    if (_points.length < 2) return null;
    final (t1, v1) = _points.last;
    var (t0, v0) = _points.first;
    final start = t1 - windowMs;
    if (t0 < start) {
      // 창 밖의 첫 점과 창 안의 둘째 점 사이를 선형 보간해 창 경계의 값을 구한다
      final (tb, vb) = _points.elementAt(1);
      v0 = v0 + (vb - v0) * (start - t0) / (tb - t0);
      t0 = start;
    }
    final span = t1 - t0;
    if (span < minSpanMs) return null;
    return (v1 - v0) / (span / 1000.0);
  }
}
