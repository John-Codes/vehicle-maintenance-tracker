import 'dart:async';

import 'pid_decoder.dart';
import 'transports/obd_transport.dart';
import 'vehicle_profile.dart';

/// The AT-command state machine shared by every ELM327-compatible dongle:
/// init, protocol auto-detect, PID requests, response collection.
class Elm327Engine {
  final ObdTransport transport;
  final _buffer = StringBuffer();
  StreamSubscription? _subscription;
  final _lines = StreamController<String>.broadcast();

  Elm327Engine(this.transport);

  Stream<String> get lines => _lines.stream;

  void _startListening() {
    _subscription?.cancel();
    _buffer.clear();
    _subscription = transport.responses.listen((chunk) {
      _buffer.write(chunk);
      var text = _buffer.toString();
      while (true) {
        final end = text.indexOf('\r');
        if (end < 0) {
          final prompt = text.indexOf('>');
          if (prompt < 0) break;
          text = text.replaceRange(prompt, prompt + 1, '');
          continue;
        }
        final line = text.substring(0, end).trim();
        text = text.substring(end + 1);
        if (line.isNotEmpty) _lines.add(line);
      }
      _buffer
        ..clear()
        ..write(text);
    });
  }

  /// Sends a command and collects lines until the adapter's '>' prompt.
  Future<List<String>> send(String command, {Duration timeout = const Duration(seconds: 5)}) async {
    _startListening();
    await transport.send(command);
    final collected = <String>[];
    try {
      await for (final line in lines.timeout(timeout, onTimeout: (_) {})) {
        collected.add(line);
      }
    } catch (_) {/* timeout reached */}
    return collected;
  }

  /// Adapter init: reset, echo off, auto protocol detection.
  Future<bool> initialize() async {
    await send('ATZ', timeout: const Duration(seconds: 3));
    final echoOff = await send('ATE0');
    if (echoOff.isEmpty) return false;
    await send('ATL0');
    await send('ATS0');
    await send('ATSP0');
    final voltage = await send('ATRV');
    return voltage.isNotEmpty;
  }

  Future<double?> readSpeedKmh() async {
    final response = (await send('010D')).join(' ');
    return PidDecoder.speedKmh(response);
  }

  Future<double?> readEngineHours() async {
    final response = (await send('011F')).join(' ');
    final minutes = PidDecoder.runtimeMinutes(response);
    return minutes == null ? null : minutes / 60.0;
  }

  /// Odometer via the vehicle profile's candidate enhanced PIDs, with a
  /// plausibility check against the record's current miles (calibration aid).
  Future<double?> readOdometer(VehicleProfile profile, {double? currentMiles}) async {
    for (final pid in profile.odometerPids) {
      final response = (await send(pid)).join(' ');
      final value = PidDecoder.odometerMiles(response, currentMiles: currentMiles);
      if (value != null) return value;
    }
    return null;
  }

  Future<void> close() async {
    await _subscription?.cancel();
    await _lines.close();
    await transport.disconnect();
  }
}
