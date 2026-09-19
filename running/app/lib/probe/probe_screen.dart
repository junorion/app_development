import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app/theme.dart';
import '../app/tokens.dart';
import '../core/format.dart';
import '../features/run/domain/run_session.dart';
import '../platform/platform_channel.dart';
import 'probe_controller.dart';

/// M0 진단 화면. 정식 화면이 아니라 사용자가 야외에서 한 번 돌리고 결과를 보내 주는 용도다.
class ProbeScreen extends StatefulWidget {
  const ProbeScreen({super.key, required this.controller});
  final ProbeController controller;

  @override
  State<ProbeScreen> createState() => _ProbeScreenState();
}

class _ProbeScreenState extends State<ProbeScreen> {
  ProbeController get c => widget.controller;
  Timer? _idlePoll;

  @override
  void initState() {
    super.initState();
    c.init().then((_) {
      if (mounted && c.unfinished.isNotEmpty) _askRecover();
    });
    // 기록하지 않을 때도 메트로놈 수치는 갱신한다
    _idlePoll = Timer.periodic(const Duration(seconds: 1), (_) => c.pollIdle());
  }

  @override
  void dispose() {
    _idlePoll?.cancel();
    super.dispose();
  }

  Future<void> _askRecover() async {
    final keep = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('끝나지 않은 기록이 있어요'),
        content: const Text('앱이 도중에 닫혔던 것 같아요. 마지막으로 저장된 곳까지 이어서 저장할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('지우기')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('저장하기')),
        ],
      ),
    );
    await c.recoverAll(keep: keep ?? true);
    if (mounted) _toast(keep == false ? '지웠어요' : '저장했어요');
  }

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _start() async {
    final err = await c.start();
    if (err != null && mounted) _toast(err);
  }

  Future<void> _stop() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('기록을 끝낼까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('계속')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('끝내기')),
        ],
      ),
    );
    if (ok == true) await c.stop();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: c,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            title: const Text('톡톡런 진단'),
            backgroundColor: Colors.transparent,
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Gap.l, 0, Gap.l, Gap.xxl),
              children: [
                _guide(context),
                const SizedBox(height: Gap.m),
                _deviceCard(context),
                const SizedBox(height: Gap.m),
                _runCard(context),
                const SizedBox(height: Gap.m),
                _diagCard(context),
                const SizedBox(height: Gap.m),
                _metronomeCard(context),
                const SizedBox(height: Gap.m),
                _shareCard(context),
              ],
            ),
          ),
        ),
      );

  Widget _guide(BuildContext context) => _Card(
        title: '이렇게 해 주세요',
        child: Text(
          '1. 밖에서 "기록 시작"을 누르고, 메트로놈도 켜 주세요.\n'
          '2. 화면을 끄고 폰을 주머니에 넣은 채 30분 이상 걷거나 달려 주세요.\n'
          '3. 화면을 켜서 "기록 끝내기"를 누르세요.\n'
          '4. "결과와 GPX 보내기"로 결과를 보내 주세요.',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.6),
        ),
      );

  Widget _deviceCard(BuildContext context) {
    final d = c.device, p = c.power;
    final ignoring = p['ignoringBatteryOptimizations'] == true;
    return _Card(
      title: '기기',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Row('모델', '${d['manufacturer'] ?? '?'} ${d['model'] ?? ''}'),
        _Row('Android', '${d['release'] ?? '?'} (API ${d['sdk'] ?? '?'})'),
        _Row('GPS', _has(d['hasGps']), bad: d['hasGps'] == false),
        _Row('걸음 센서', _has(d['hasStepCounter']), bad: d['hasStepCounter'] == false),
        for (final e in c.perms.entries)
          _Row('${e.key} 권한', e.value.isGranted ? '허용' : '아직 없음', bad: !e.value.isGranted),
        _Row('배터리 최적화', ignoring ? '제외됨' : '적용 중'),
        _Row('절전 모드', p['powerSave'] == true ? '켜짐' : '꺼짐', bad: p['powerSave'] == true),
        if (d['hasGps'] == false || d['hasStepCounter'] == false)
          Padding(
            padding: const EdgeInsets.only(top: Gap.s),
            child: Text(
              d['hasGps'] == false
                  ? '이 기기에는 GPS 가 없어 야외 기록 시험을 할 수 없어요.'
                  : '걸음 센서가 없어 케이던스는 --로 보여요. 나머지는 시험할 수 있어요.',
              style: TextStyle(color: context.palette.danger),
            ),
          ),
        const SizedBox(height: Gap.s),
        OutlinedButton(
          onPressed: PlatformChannel.openBatterySettings,
          child: const Text('배터리 최적화 설정 열기'),
        ),
      ]),
    );
  }

  Widget _runCard(BuildContext context) {
    final s = c.session;
    final t = Theme.of(context).textTheme;
    final pal = context.palette;
    final end = s?.endedAtMs ?? c.now;
    final moving = s?.startedAtMs == null ? 0.0 : s!.movingSecAt(end);
    return _Card(
      title: '기록',
      trailing: s == null ? null : Text(_state(s.state), style: TextStyle(color: pal.textSub)),
      child: Column(children: [
        Row(children: [
          Expanded(child: _Metric(formatKm(s?.distanceM ?? 0), 'km', big: true)),
          Expanded(child: _Metric(formatDuration(moving), '이동 시간', big: true)),
        ]),
        const SizedBox(height: Gap.m),
        Row(children: [
          Expanded(child: _Metric(formatPace(s?.currentSpeedMps), '현재 페이스')),
          Expanded(child: _Metric(s?.currentCadenceSpm?.round().toString() ?? '--', '케이던스')),
          Expanded(child: _Metric(s?.steps?.round().toString() ?? '--', '걸음')),
        ]),
        const SizedBox(height: Gap.l),
        if (!c.recording)
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _start, child: Text('기록 시작', style: t.titleLarge!.copyWith(color: pal.onPrimary))),
          )
        else
          Row(children: [
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: pal.accent, foregroundColor: pal.onAccent),
                onPressed: c.togglePause,
                child: Text(s!.state == RunState.paused ? '다시 시작' : '일시정지'),
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: pal.danger, foregroundColor: pal.onDanger),
                onPressed: _stop,
                child: const Text('기록 끝내기'),
              ),
            ),
          ]),
      ]),
    );
  }

  Widget _diagCard(BuildContext context) {
    final s = c.session;
    return _Card(
      title: '진단',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Row('위치', c.locGaps.describe(), bad: c.locGaps.longGaps > 0),
        _Row('평균 정확도', '${c.avgAccuracy.toStringAsFixed(1)}m'),
        if (s != null)
          _Row('버린 위치', s.filter.rejected.entries.where((e) => e.value > 0).map((e) => '${e.key.name} ${e.value}').join(' · ').ifEmpty('없음')),
        _Row('걸음 이벤트', c.stepGaps.describe()),
        _Row('백그라운드', '${c.bgEntries}번 · ${formatDuration(c.bgMsNow / 1000)}'),
        _Row('그동안 받은 것', '위치 ${c.bgLocations} · 걸음 ${c.bgSteps}'),
        if (s != null && s.allSplits.isNotEmpty)
          _Row('스플릿', s.allSplits.map((e) => formatDuration(e.durationSec)).join(' / ')),
        if (c.locError != null) _Row('위치 오류', c.locError!, bad: true),
        if (c.stepError != null) _Row('걸음 오류', c.stepError!, bad: true),
      ]),
    );
  }

  Widget _metronomeCard(BuildContext context) {
    final m = c.metroStats;
    final pal = context.palette;
    return _Card(
      title: '메트로놈',
      trailing: Switch(value: c.metronomeOn, onChanged: (_) => c.toggleMetronome()),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          IconButton.filledTonal(onPressed: () => c.setSpm(c.spm - 1), icon: const Icon(Icons.remove_rounded)),
          Expanded(
            child: Column(children: [
              Text('${c.spm.round()}', style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontFeatures: tabular)),
              Text('spm', style: TextStyle(color: pal.textSub)),
            ]),
          ),
          IconButton.filledTonal(onPressed: () => c.setSpm(c.spm + 1), icon: const Icon(Icons.add_rounded)),
        ]),
        Slider(value: c.spm, min: 100, max: 220, divisions: 120, onChanged: c.setSpm),
        if (m.isNotEmpty) ...[
          _Row('재생', '${m['ticks']}박 · ${formatDuration((m['seconds'] as num? ?? 0))}'),
          _Row('끊김(underrun)', '${m['underruns']}번', bad: (m['underruns'] as num? ?? 0) > 0),
          _Row('출력 시계 어긋남', '최대 ${(m['maxClockDevMs'] as num? ?? 0).toStringAsFixed(1)}ms',
              bad: (m['maxClockDevMs'] as num? ?? 0) > 10),
          _Row('비교: Dart Timer', c.dartJitterFg.describe()),
          _Row('  └ 백그라운드', c.dartJitterBg.describe()),
        ],
      ]),
    );
  }

  Widget _shareCard(BuildContext context) => _Card(
        title: '보내기',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          FilledButton.tonal(
            onPressed: c.session?.track.isNotEmpty == true ? c.shareGpx : null,
            child: const Text('결과와 GPX 보내기'),
          ),
          const SizedBox(height: Gap.s),
          OutlinedButton(onPressed: c.shareReport, child: const Text('결과만 보내기')),
        ]),
      );

  static String _has(Object? v) => v == true ? '있음' : (v == false ? '없음' : '?');
  static String _state(RunState s) => switch (s) {
        RunState.running => '기록 중',
        RunState.paused => '일시정지',
        RunState.autoPaused => '자동 일시정지',
        RunState.finished => '끝남',
        _ => '',
      };
}

extension on String {
  String ifEmpty(String v) => isEmpty ? v : this;
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.all(Gap.l),
      decoration: BoxDecoration(
        color: tk.palette.surface,
        borderRadius: BorderRadius.circular(tk.cardRadius),
        boxShadow: tk.softShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
          ?trailing,
        ]),
        const SizedBox(height: Gap.m),
        child,
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.bad = false});
  final String label, value;
  final bool bad;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 120, child: Text(label, style: TextStyle(color: p.textSub))),
        Expanded(
          child: Text(value,
              style: TextStyle(color: bad ? p.danger : p.text, fontFeatures: tabular)),
        ),
      ]),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.value, this.label, {this.big = false});
  final String value, label;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(children: [
      FittedBox(
        child: Text(value,
            style: (big ? t.displayLarge!.copyWith(fontSize: 44) : t.headlineMedium)!
                .copyWith(fontFeatures: tabular)),
      ),
      Text(label, style: t.bodySmall),
    ]);
  }
}
