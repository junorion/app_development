import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app/services.dart';
import 'processing.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.services});
  final Services services;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.services.share.incoming.listen(_openShared);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final first = await widget.services.share.takeInitial();
      if (first != null) _openShared(first);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _openShared(String uri) async {
    final name = await widget.services.share.displayName(uri);
    if (mounted) _start(PickedAudio(uri, name));
  }

  Future<void> _pick() async {
    final picker = widget.services.pickAudio ?? _defaultPick;
    final picked = await picker();
    if (picked != null && mounted) _start(picked);
  }

  static Future<PickedAudio?> _defaultPick() async {
    final f = await FilePicker.pickFile(type: FileType.audio);
    if (f == null) return null;
    // 안드로이드는 content:// 를 줄 수 있다 — 네이티브 디코더가 그대로 읽는다
    return PickedAudio(f.path ?? f.uri.toString(), f.name);
  }

  void _start(PickedAudio a) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProcessingScreen(services: widget.services, audio: a)));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('악보 추출')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.queue_music_rounded, size: 72, color: t.colorScheme.primary),
                  const SizedBox(height: 20),
                  Text('음원을 악보로', textAlign: TextAlign.center, style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('가지고 있는 음원 파일(mp3 · m4a · wav · flac)을 열면\n폰 안에서 악보로 바꿉니다. 인터넷이 필요 없습니다.',
                      textAlign: TextAlign.center, style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant, height: 1.5)),
                  const SizedBox(height: 32),
                  FilledButton.icon(onPressed: _pick, icon: const Icon(Icons.folder_open_rounded), label: const Text('음원 파일 열기')),
                  const SizedBox(height: 12),
                  Text('다른 앱에서 "공유하기 → 악보 추출"로 보내도 됩니다.',
                      textAlign: TextAlign.center, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
