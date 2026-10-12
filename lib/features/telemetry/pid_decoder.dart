/// PID response decoding for ELM327 adapters. Pure functions — unit-tested
/// against recorded real adapter bytes in test/pid_decoder_test.dart.
class PidDecoder {
  static final _hex = RegExp(r'^[0-9A-Fa-f]+$');

  static List<int> _hexBytes(String response) {
    final tokens = response
        .split(RegExp(r'[\s,]+'))
        .where((token) => token.length <= 4 && _hex.hasMatch(token))
        .toList();
    final bytes = <int>[];
    for (final token in tokens) {
      final value = int.tryParse(token, radix: 16);
      if (value == null) return [];
      bytes.add(value);
    }
    return bytes;
  }

  /// SAE speed: the adapter answers "41 0D 55" for 0x55 km/h.
  static double? speedKmh(String response) {
    final bytes = _hexBytes(response);
    final i = _indexOf(bytes, [0x41, 0x0D]);
    if (i == null || i + 2 >= bytes.length) return null;
    return bytes[i + 2].toDouble();
  }

  /// SAE engine runtime: "41 1F AA BB" -> minutes.
  static double? runtimeMinutes(String response) {
    final bytes = _hexBytes(response);
    final i = _indexOf(bytes, [0x41, 0x1F]);
    if (i == null || i + 3 > bytes.length - 1) return null;
    return ((bytes[i + 2] << 8) + bytes[i + 3]).toDouble();
  }

  /// Enhanced (mode 0x22) odometer. A "62 [pid] [pid]" header precedes the
  /// value bytes; multi-frame responses arrive as several "62 ..." lines.
  /// We take the largest plausible payload. A value within ~1.6x of the
  /// record's current miles was probably reported in kilometers and gets
  /// converted.
  static double? odometerMiles(String response, {double? currentMiles}) {
    final bytes = _hexBytes(response);
    var best = 0;
    for (var i = 0; i + 3 < bytes.length; i++) {
      if (bytes[i] != 0x62) continue;
      for (final width in [4, 3]) {
        if (i + 3 + width > bytes.length) continue;
        var value = 0;
        for (var b = 0; b < width; b++) {
          value = (value << 8) + bytes[i + 3 + b];
        }
        if (value > best && value < 20000000) best = value;
      }
    }
    if (best == 0) return null;
    if (currentMiles != null && currentMiles > 100) {
      final ratio = best / currentMiles;
      if (ratio > 1.35 && ratio < 1.85) return best / 1.609;
    }
    return best.toDouble();
  }

  static int? _indexOf(List<int> bytes, List<int> pattern) {
    for (var i = 0; i + pattern.length <= bytes.length; i++) {
      var match = true;
      for (var j = 0; j < pattern.length; j++) {
        if (bytes[i + j] != pattern[j]) {
          match = false;
          break;
        }
      }
      if (match) return i;
    }
    return null;
  }
}
