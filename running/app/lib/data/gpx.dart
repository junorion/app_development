import '../features/run/domain/location_sample.dart';
import '../features/run/domain/run_session.dart';

/// GPX 1.1 내보내기 (지침 9.3). 일시정지로 끊긴 구간마다 `<trkseg>` 를 나눈다.
String toGpx(List<TrackPoint> track, {required String name, String creator = 'Running'}) {
  final b = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln('<gpx version="1.1" creator="${_esc(creator)}" '
        'xmlns="http://www.topografix.com/GPX/1/1">')
    ..writeln('  <trk>')
    ..writeln('    <name>${_esc(name)}</name>')
    ..writeln('    <type>running</type>');
  int? seg;
  for (final p in track) {
    if (p.segmentIndex != seg) {
      if (seg != null) b.writeln('    </trkseg>');
      b.writeln('    <trkseg>');
      seg = p.segmentIndex;
    }
    final s = p.sample;
    b.write('      <trkpt lat="${s.lat.toStringAsFixed(7)}" lon="${s.lng.toStringAsFixed(7)}">');
    if (s.altitudeM != null) b.write('<ele>${s.altitudeM!.toStringAsFixed(1)}</ele>');
    b.writeln('<time>${_iso(s.tMs)}</time></trkpt>');
  }
  if (seg != null) b.writeln('    </trkseg>');
  b
    ..writeln('  </trk>')
    ..writeln('</gpx>');
  return b.toString();
}

/// GPX 를 읽어 위치 샘플로 (GPX 재생용 가짜 위치 소스, 지침 2장·11.2).
/// GPX 에는 정확도가 없으므로 [accuracyM] 으로 채운다. `<hdop>` 가 있으면 ×5m 로 어림한다.
/// 구간 번호는 `<trkseg>` 순서. 시각이 없는 점은 건너뛴다.
List<(LocationSample, int)> parseGpx(String gpx, {double accuracyM = 5}) {
  final out = <(LocationSample, int)>[];
  final segRe = RegExp(r'<trkseg\b[^>]*>(.*?)</trkseg>', dotAll: true);
  final ptRe = RegExp(r'<trkpt\b([^>]*)>(.*?)</trkpt>', dotAll: true);
  var seg = 0;
  for (final sm in segRe.allMatches(gpx)) {
    for (final pm in ptRe.allMatches(sm.group(1)!)) {
      final attrs = pm.group(1)!;
      final body = pm.group(2)!;
      final lat = double.tryParse(_attr(attrs, 'lat') ?? '');
      final lng = double.tryParse(_attr(attrs, 'lon') ?? '');
      final time = _tag(body, 'time');
      if (lat == null || lng == null || time == null) continue;
      final t = DateTime.tryParse(time);
      if (t == null) continue;
      final hdop = double.tryParse(_tag(body, 'hdop') ?? '');
      out.add((
        LocationSample(
          tMs: t.millisecondsSinceEpoch,
          lat: lat,
          lng: lng,
          accuracyM: hdop != null ? hdop * 5 : accuracyM,
          altitudeM: double.tryParse(_tag(body, 'ele') ?? ''),
        ),
        seg,
      ));
    }
    seg++;
  }
  return out;
}

String? _attr(String attrs, String name) =>
    RegExp('\\b$name\\s*=\\s*["\']([^"\']*)["\']').firstMatch(attrs)?.group(1);

String? _tag(String body, String name) =>
    RegExp('<$name>\\s*([^<]*?)\\s*</$name>').firstMatch(body)?.group(1);

String _iso(int ms) {
  final s = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toIso8601String();
  // 밀리초가 0 이면 잘라서 흔한 GPX 형식(…T12:00:00Z)에 맞춘다
  return s.endsWith('.000Z') ? '${s.substring(0, s.length - 5)}Z' : s;
}

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
