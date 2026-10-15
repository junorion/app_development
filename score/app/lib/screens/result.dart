import 'package:flutter/material.dart';

import '../engine/engine.dart';

/// 임시 결과 화면 — D-3 악보 뷰어가 생기기 전까지 음표 요약만 보여 준다.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.title, required this.result, required this.took});
  final String title;
  final TranscriptionResult result;
  final Duration took;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final notes = result.notes;
    final lo = notes.isEmpty ? 0 : notes.map((n) => n.pitch).reduce((a, b) => a < b ? a : b);
    final hi = notes.isEmpty ? 0 : notes.map((n) => n.pitch).reduce((a, b) => a > b ? a : b);
    return Scaffold(
      appBar: AppBar(title: Text(title, overflow: TextOverflow.ellipsis)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _row(t, '길이', '${result.seconds.toStringAsFixed(1)}초'),
        _row(t, '찾은 음표', '${notes.length}개'),
        if (notes.isNotEmpty) _row(t, '음역', '${noteName(lo)} ~ ${noteName(hi)}'),
        _row(t, '걸린 시간', '${(took.inMilliseconds / 1000).toStringAsFixed(1)}초'),
        const Divider(height: 32),
        Text('처음 20개', style: t.textTheme.titleSmall),
        for (final n in notes.take(20))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text('${n.onset.toStringAsFixed(2)}s  ${noteName(n.pitch)}  ${(n.offset - n.onset).toStringAsFixed(2)}s',
                style: t.textTheme.bodyMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
          ),
      ]),
    );
  }

  Widget _row(ThemeData t, String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          SizedBox(width: 96, child: Text(k, style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant))),
          Expanded(child: Text(v, style: t.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600))),
        ]),
      );
}

const _names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
String noteName(int midi) => '${_names[midi % 12]}${midi ~/ 12 - 1}';
