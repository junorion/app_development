import '../../../data/run_repository.dart';
import '../domain/run_session.dart';

/// 세션을 [intervalMs] 마다 DB 에 옮겨 적는다 (지침 5.7 — 5~10초). 앱이 죽어도 마지막 저장
/// 시점까지는 남는다. 저장은 한 번에 하나씩만 돈다 — 느린 기기에서 겹치면 점이 두 번 들어간다.
class RunRecorder {
  RunRecorder(this.repo, this.session, this.runId, {this.intervalMs = 5000});

  final RunRepository repo;
  final RunSession session;
  final String runId;
  final int intervalMs;

  int _savedPoints = 0;
  int _savedSplits = 0;
  int? _lastSaveMs;
  Future<void> _chain = Future.value();

  /// 1초마다 부른다. 저장할 때가 됐으면 저장한다.
  Future<void> onTick(int tMs) {
    final last = _lastSaveMs;
    if (last != null && tMs - last < intervalMs) return _chain;
    _lastSaveMs = tMs;
    return save(tMs);
  }

  /// 상태가 바뀔 때(일시정지 등)도 부른다 (지침 5.1)
  Future<void> save(int tMs) => _chain = _chain.then((_) => _save(tMs));

  Future<void> finish(int tMs) => _chain = _chain.then((_) async {
        await _save(tMs);
        await repo.finishRun(runId, endedAtMs: tMs, splits: session.allSplits);
      });

  Future<void> _save(int tMs) async {
    final pts = session.track.sublist(_savedPoints);
    final splits = session.splits.splits.sublist(_savedSplits);
    await repo.saveProgress(
      runId,
      points: pts,
      newSplits: splits,
      tMs: tMs,
      distanceM: session.distanceM,
      movingSec: session.movingSecAt(tMs),
      steps: session.steps,
    );
    _savedPoints += pts.length;
    _savedSplits += splits.length;
  }
}
