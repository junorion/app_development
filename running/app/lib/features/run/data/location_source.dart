import 'dart:async';

import '../domain/location_sample.dart';

/// 위치 소스. 실제 GPS 와 GPX 재생을 바꿔 끼운다 (지침 2장 계층 원칙).
abstract interface class LocationSource {
  /// 고정밀 수집 시작. 러닝 중에만 쓴다 (지침 5.2, 11.1 배터리).
  Stream<LocationSample> start();
  Future<void> stop();
}

/// 저장된 샘플을 [speedup] 배속으로 흘려보내는 가짜 소스. 시각은 지금 시각 기준으로 옮긴다.
class ReplayLocationSource implements LocationSource {
  ReplayLocationSource(this.samples, {this.speedup = 1});

  final List<LocationSample> samples;
  final double speedup;
  StreamController<LocationSample>? _ctl;
  Timer? _timer;

  @override
  Stream<LocationSample> start() {
    final ctl = _ctl = StreamController<LocationSample>();
    if (samples.isEmpty) {
      ctl.close();
      return ctl.stream;
    }
    final origin = samples.first.tMs;
    final wallStart = DateTime.now().millisecondsSinceEpoch;
    var i = 0;
    void next() {
      if (i >= samples.length) {
        ctl.close();
        return;
      }
      final s = samples[i++];
      final at = wallStart + ((s.tMs - origin) / speedup).round();
      ctl.add(LocationSample(
          tMs: at, lat: s.lat, lng: s.lng, accuracyM: s.accuracyM,
          speedMps: s.speedMps, altitudeM: s.altitudeM));
      if (i < samples.length) {
        final wait = ((samples[i].tMs - s.tMs) / speedup).round();
        _timer = Timer(Duration(milliseconds: wait), next);
      } else {
        ctl.close();
      }
    }

    next();
    return ctl.stream;
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    await _ctl?.close();
  }
}
