import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_maintenance_tracker/features/telemetry/pid_decoder.dart';

/// Unit tests against recorded real ELM327 adapter response bytes
/// (Veepeak-class dongles). These are pure decoder tests — the full record
/// update path is covered end-to-end by backend/e2e_schedule.py.
void main() {
  test('decodes SAE vehicle speed', () {
    // "010D" request; adapter answers with 0x55 = 85 km/h.
    expect(PidDecoder.speedKmh('41 0D 55'), 85.0);
    expect(PidDecoder.speedKmh('SEARCHING...\r41 0D 00'), 0.0);
  });

  test('decodes SAE engine runtime minutes', () {
    // "41 1F 1E 61" -> (0x1E << 8) + 0x61 = 7777 minutes.
    expect(PidDecoder.runtimeMinutes('41 1F 1E 61'), 7777.0);
  });

  test('decodes enhanced odometer in miles', () {
    // Toyota-style "22 F1 90" response; value 0x022C0E = 142350 miles.
    expect(PidDecoder.odometerMiles('62 F1 90 02 2C 0E'), 142350.0);
    // 4-byte value with leading zeros reads the same.
    expect(PidDecoder.odometerMiles('62 F1 90 00 02 2C 0E'), 142350.0);
  });

  test('converts kilometer odometers when they are ~1.6x current miles', () {
    // Adapter reported 160774 (km) while the record says 100000 miles.
    final value = PidDecoder.odometerMiles('62 F1 90 02 74 06',
        currentMiles: 100000);
    expect(value, closeTo(160774 / 1.609, 0.5));
  });

  test('keeps raw miles when close to the current record', () {
    final value = PidDecoder.odometerMiles('62 F1 90 02 2C 0E',
        currentMiles: 140000);
    expect(value, 142350.0);
  });

  test('rejects junk and NO DATA responses', () {
    expect(PidDecoder.speedKmh('NO DATA'), isNull);
    expect(PidDecoder.runtimeMinutes('STOPPED'), isNull);
    expect(PidDecoder.odometerMiles('NO DATA'), isNull);
    expect(PidDecoder.odometerMiles('UNABLE TO CONNECT'), isNull);
  });
}
