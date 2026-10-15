import 'dart:async';

import 'package:flutter/services.dart';

/// 다른 앱에서 "공유하기"로 들어온 오디오 파일 (content:// URI).
class ShareInbox {
  ShareInbox({MethodChannel? channel}) : _ch = channel ?? const MethodChannel('score/engine') {
    _ch.setMethodCallHandler((call) async {
      if (call.method == 'shared') _incoming.add(call.arguments as String);
    });
  }

  final MethodChannel _ch;
  final _incoming = StreamController<String>.broadcast();

  /// 앱이 떠 있는 동안 새로 공유된 것.
  Stream<String> get incoming => _incoming.stream;

  /// 앱을 공유로 열었을 때의 첫 파일 (한 번만 돌려준다).
  Future<String?> takeInitial() async {
    try {
      return await _ch.invokeMethod<String>('takeShared');
    } on MissingPluginException {
      return null;
    }
  }

  Future<String> displayName(String uri) async {
    try {
      return await _ch.invokeMethod<String>('displayName', {'uri': uri}) ?? _fallback(uri);
    } on MissingPluginException {
      return _fallback(uri);
    }
  }

  static String _fallback(String uri) => Uri.decodeComponent(uri.split('/').last);
}
