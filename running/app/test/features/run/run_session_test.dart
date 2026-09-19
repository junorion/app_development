import 'package:flutter_test/flutter_test.dart';
import 'package:running/features/run/domain/location_sample.dart';
import 'package:running/features/run/domain/run_session.dart';

const mPerDegLat = 111195.08;

/// 1초에 한 번 위치·걸음·tick 을 넣는 가짜 러너. 북쪽으로만 달린다.
class Runner {
  Runner(this.session, {this.t0 = 1000000});
  final RunSession session;
  final int t0;
  int sec = 0;
  double posM = 0;
  double stepsCum = 50000; // 부팅 후 누적값처럼 큰 수에서 시작

  int get t => t0 + sec * 1000;

  void start() {
    session
      ..startCountdown()
      ..onSteps(t, stepsCum)
      ..begin(t);
    _feed();
  }

  /// [speed] m/s, 초당 [spsteps] 걸음으로 [n] 초
  void run(int n, double speed, {double spsteps = 3, double accuracy = 5}) {
    for (var i = 0; i < n; i++) {
      sec++;
      posM += speed;
      stepsCum += spsteps;
      _feed(accuracy: accuracy);
    }
  }

  void _feed({double accuracy = 5}) {
    session
      ..onLocation(LocationSample(
          tMs: t, lat: 37.5 + posM / mPerDegLat, lng: 127.0, accuracyM: accuracy))
      ..onSteps(t, stepsCum)
      ..tick(t);
  }
}

void main() {
  test('3m/s 로 400초 — 거리·스플릿·현재값', () {
    final splits = [];
    final r = Runner(RunSession(onSplit: splits.add))..start();
    r.run(400, 3);
    final s = r.session;
    expect(s.distanceM, closeTo(1200, 1));
    expect(splits, hasLength(1));
    expect(splits.single.durationSec, closeTo(1000 / 3, 0.5));
    expect(splits.single.avgCadenceSpm, closeTo(180, 1));
    expect(s.currentSpeedMps, closeTo(3, 0.01));
    expect(s.currentCadenceSpm, closeTo(180, 0.5));
    expect(s.avgCadenceSpmAt(r.t), closeTo(180, 0.5));
    expect(s.movingSecAt(r.t), 400);
  });

  test('신호 대기 — 멈추면 자동 일시정지, 달리면 재개, 멈춘 시간은 이동 시간에서 빠진다', () {
    final states = <RunState>[];
    final r = Runner(RunSession(onState: (_, to) => states.add(to)))..start();
    r.run(100, 3);
    r.run(60, 0, spsteps: 0);
    expect(r.session.state, RunState.autoPaused);
    r.run(100, 3);
    expect(r.session.state, RunState.running);
    expect(states, [RunState.countdown, RunState.running, RunState.autoPaused, RunState.running]);
    expect(r.session.distanceM, closeTo(600, 1));
    // 멈춘 60초 중 판정에 걸린 시간(속도가 내려가는 데 몇 초 + 4초)만 이동 시간에 남는다
    final moving = r.session.movingSecAt(r.t);
    expect(moving, greaterThan(200));
    expect(moving, lessThan(215));
  });

  test('자동 일시정지를 끄면 멈춰도 계속 센다', () {
    final r = Runner(RunSession(autoPauseEnabled: false))..start();
    r.run(100, 3);
    r.run(60, 0, spsteps: 0);
    expect(r.session.state, RunState.running);
    expect(r.session.currentSpeedMps, closeTo(0, 1e-9));
    expect(r.session.movingSecAt(r.t), 160);
  });

  test('수동 일시정지 — 멈춘 사이 이동한 거리는 넣지 않고 구간을 나눈다', () {
    final r = Runner(RunSession())..start();
    r.run(100, 3);
    r.session.pause(r.t);
    r.run(100, 2); // 걸어서 200m 이동하지만 기록하지 않는다
    r.session.resume(r.t);
    r.run(100, 3);
    r.session.finish(r.t);
    final s = r.session;
    expect(s.distanceM, closeTo(597, 3)); // 재개 직후 첫 점은 기준점만 잡는다
    expect(s.movingSecAt(r.t), 200);
    expect(s.track.map((p) => p.segmentIndex).toSet(), {0, 1});
    expect(s.steps, closeTo(600, 1)); // 멈춘 사이 걸음(200)은 빠진다
  });

  test('GPS 가 튀어도 거리가 늘지 않는다', () {
    final r = Runner(RunSession())..start();
    r.run(50, 3);
    // 정확도가 나쁜 점(고층 건물 사이)
    r.run(10, 3, accuracy: 60);
    r.run(50, 3);
    expect(r.session.distanceM, closeTo(330, 1));
    expect(r.session.filter.rejected.values.reduce((a, b) => a + b), 10);
  });

  test('종료하면 마지막 미완 구간이 부분 스플릿으로 붙는다', () {
    final r = Runner(RunSession())..start();
    r.run(500, 3);
    r.session.finish(r.t);
    final all = r.session.allSplits;
    expect(all, hasLength(2));
    expect(all.last.isPartial, isTrue);
    expect(all.last.distanceM, closeTo(500, 1));
  });

  test('걸음 센서가 없으면 케이던스는 null', () {
    final s = RunSession()
      ..startCountdown()
      ..begin(0);
    for (var i = 1; i <= 30; i++) {
      s
        ..onLocation(LocationSample(tMs: i * 1000, lat: 37.5 + i * 3 / mPerDegLat, lng: 127, accuracyM: 5))
        ..tick(i * 1000);
    }
    expect(s.steps, isNull);
    expect(s.currentCadenceSpm, isNull);
    expect(s.avgCadenceSpmAt(30000), isNull);
    expect(s.distanceM, closeTo(87, 1));
  });

  test('잘못된 전이는 막는다', () {
    final s = RunSession();
    expect(() => s.pause(0), throwsStateError);
    expect(() => s.finish(0), throwsStateError);
  });
}
