import 'geo.dart';
import 'location_sample.dart';

/// 샘플을 버린 이유. 진단 화면에서 이유별로 센다.
enum RejectReason { inaccurate, nonMonotonic, tooClose, tooFast }

class FilterConfig {
  const FilterConfig({
    this.maxAccuracyM = 25,
    this.maxSpeedMps = 12,
    this.minMoveM = 2.5,
  });

  /// 정확도 반경이 이보다 크면 버린다 (지침 5.2)
  final double maxAccuracyM;

  /// 직전 유효 점에서 이 속도를 넘는 이동은 순간 튐으로 보고 버린다
  final double maxSpeedMps;

  /// 이보다 가까운 이동은 정지 상태의 GPS 드리프트로 보고 무시한다
  final double minMoveM;
}

class FilterResult {
  const FilterResult.accepted(this.distanceM, this.dtMs) : reason = null;
  const FilterResult.rejected(this.reason)
      : distanceM = 0,
        dtMs = 0;

  final RejectReason? reason;

  /// 직전 유효 점에서 이 점까지의 거리. 구간의 첫 점이면 0.
  final double distanceM;
  final int dtMs;

  bool get isAccepted => reason == null;
}

/// 위치 노이즈 필터. 직전에 받아들인 점을 기준(anchor)으로 새 점을 판정한다.
///
/// 버린 점은 기준을 바꾸지 않는다 — 튄 점 하나 때문에 다음 정상 점까지 버려지면 안 된다.
/// 일시정지 후 재개처럼 경로가 끊기는 곳에서는 [reset] 으로 기준을 비운다.
class NoiseFilter {
  NoiseFilter([this.config = const FilterConfig()]);

  final FilterConfig config;
  LocationSample? _anchor;
  final Map<RejectReason, int> rejected = {for (final r in RejectReason.values) r: 0};
  int acceptedCount = 0;

  LocationSample? get anchor => _anchor;

  void reset() => _anchor = null;

  FilterResult add(LocationSample s) {
    final r = _judge(s);
    if (r.isAccepted) {
      _anchor = s;
      acceptedCount++;
    } else {
      rejected[r.reason!] = rejected[r.reason!]! + 1;
    }
    return r;
  }

  FilterResult _judge(LocationSample s) {
    if (s.accuracyM > config.maxAccuracyM) {
      return const FilterResult.rejected(RejectReason.inaccurate);
    }
    final a = _anchor;
    // 첫 유효 샘플은 기준만 잡고 거리를 누적하지 않는다 (지침 5.2)
    if (a == null) return const FilterResult.accepted(0, 0);

    final dt = s.tMs - a.tMs;
    if (dt <= 0) return const FilterResult.rejected(RejectReason.nonMonotonic);

    final d = haversineM(a.lat, a.lng, s.lat, s.lng);
    if (d < config.minMoveM) return const FilterResult.rejected(RejectReason.tooClose);
    if (d / (dt / 1000.0) > config.maxSpeedMps) {
      return const FilterResult.rejected(RejectReason.tooFast);
    }
    return FilterResult.accepted(d, dt);
  }
}
