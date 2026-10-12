import 'dart:async';

import 'obd_transport.dart';

/// Placeholder for platforms without BLE support (iOS Safari, and web until
/// the Web Bluetooth branch lands). Gives clear, plain-English errors.
class UnsupportedBleTransport implements ObdTransport {
  @override
  bool get isSupported => false;

  @override
  Stream<String> get responses => const Stream.empty();

  @override
  Future<List<DiscoveredAdapter>> discover({Duration timeout = const Duration(seconds: 6)}) async =>
      throw Exception('Bluetooth adapters are not supported on this browser. '
          'Use the Android app, or type the miles in.');

  @override
  Future<void> connect(String deviceId) async =>
      throw Exception('Bluetooth is not available on this device.');

  @override
  Future<void> send(String command) async {}

  @override
  Future<void> disconnect() async {}
}

ObdTransport createBleTransport() => UnsupportedBleTransport();
