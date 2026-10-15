import '../engine/engine.dart';
import '../platform/share.dart';

/// 화면이 쓰는 바깥 의존성 — 테스트에서 가짜로 바꿔 끼운다.
class Services {
  Services({TranscriptionEngine? engine, ShareInbox? share, this.pickAudio})
      : engine = engine ?? TranscriptionEngine(),
        share = share ?? ShareInbox();

  final TranscriptionEngine engine;
  final ShareInbox share;

  /// 파일 선택기. null 이면 기본(file_picker).
  final Future<PickedAudio?> Function()? pickAudio;
}

class PickedAudio {
  const PickedAudio(this.path, this.name);
  final String path;
  final String name;
}
