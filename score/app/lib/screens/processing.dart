import 'package:flutter/material.dart';

import '../app/services.dart';
import '../engine/engine.dart';
import 'result.dart';

/// 변환 진행 — 디코드 → 채보. 실패하면 이유를 보여 주고 돌아가게 한다.
class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key, required this.services, required this.audio});
  final Services services;
  final PickedAudio audio;

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  double _progress = 0;
  String? _error;
  final _watch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    _watch.start();
    try {
      final r = await widget.services.engine.transcribe(widget.audio.path, onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      });
      _watch.stop();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ResultScreen(title: _title(widget.audio.name), result: r, took: _watch.elapsed),
      ));
    } on EngineException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = '알 수 없는 오류: $e');
    }
  }

  static String _title(String name) {
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_title(widget.audio.name), overflow: TextOverflow.ellipsis)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _error == null ? _busy(t) : _failed(t),
            ),
          ),
        ),
      ),
    );
  }

  Widget _busy(ThemeData t) {
    final stage = _progress < 0.1 ? '음원 읽는 중' : (_progress < 1 ? '음을 듣는 중' : '정리하는 중');
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(stage, style: t.textTheme.titleMedium),
      const SizedBox(height: 16),
      LinearProgressIndicator(value: _progress, minHeight: 8, borderRadius: BorderRadius.circular(4)),
      const SizedBox(height: 8),
      Text('${(_progress * 100).round()}%', style: t.textTheme.bodySmall),
    ]);
  }

  Widget _failed(ThemeData t) => Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline_rounded, size: 48, color: t.colorScheme.error),
        const SizedBox(height: 12),
        Text(_error!, textAlign: TextAlign.center, style: t.textTheme.titleMedium),
        const SizedBox(height: 24),
        OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('돌아가기')),
      ]);
}
