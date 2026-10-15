/// 초 단위 음표 — 파이프라인의 공통 형식 (Python scoreapp.notes.Note 와 같다).
class Note {
  const Note(this.onset, this.offset, this.pitch, [this.velocity = 80]);
  final double onset;
  final double offset;
  final int pitch;
  final int velocity;

  @override
  String toString() => 'Note(${onset.toStringAsFixed(3)}, ${offset.toStringAsFixed(3)}, $pitch)';
}
