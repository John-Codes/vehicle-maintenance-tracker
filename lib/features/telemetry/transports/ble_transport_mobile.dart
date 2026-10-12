import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'ble_uuid_tools.dart';
import 'obd_transport.dart';
import '../scanner_registry.dart';

/// BLE transport for Android and iOS: discovers and talks to any
/// ELM327-over-BLE adapter (Veepeak, OBDLink, Vgate, generic clones).
class BleTransportMobile implements ObdTransport {
  final _ble = FlutterReactiveBle();
  final _incoming = StreamController<String>.broadcast();
  StreamSubscription? _connection;
  StreamSubscription? _notify;
  QualifiedCharacteristic? _txChar;

  @override
  bool get isSupported => !kIsWeb;

  @override
  Stream<String> get responses => _incoming.stream;

  @override
  Future<List<DiscoveredAdapter>> discover(
      {Duration timeout = const Duration(seconds: 8)}) async {
    final found = <String, DiscoveredAdapter>{};
    final uuids = ScannerRegistry.allServiceUuids.map(_parseUuid).toList();
    final scan = _ble.scanForDevices(withServices: uuids, scanMode: ScanMode.balanced);
    final completer = Completer<void>();
    final subscription = scan.listen((device) {
      final info = ScannerRegistry.match(device.name) ?? ScannerRegistry.entries.last;
      final existing = found[device.id];
      if (existing == null || device.rssi > existing.rssi) {
        found[device.id] = DiscoveredAdapter(device.id, info.label, device.rssi);
      }
    });
    Timer(timeout, () {
      subscription.cancel();
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
    return found.values.toList();
  }

  @override
  Future<void> connect(String deviceId) async {
    final connection = _ble.connectToDevice(
        id: deviceId, connectionTimeout: const Duration(seconds: 12));
    _connection = connection.listen((state) {}, onError: (Object error) {
      _incoming.addError(error);
    });
    await connection.firstWhere(
        (state) => state.connectionState == DeviceConnectionState.connected);
    await _ble.discoverAllServices(deviceId);
    final services = await _ble.getDiscoveredServices(deviceId);
    for (final service in services) {
      for (final char in service.characteristics) {
        final qualified = QualifiedCharacteristic(
            characteristicId: char.id, serviceId: service.id, deviceId: deviceId);
        final isNotifyHint = isNotifyShortUuid(char.id) && char.isNotifiable;
        final isNotifyFallback = _notify == null &&
            char.isNotifiable &&
            !char.isWritableWithResponse &&
            !isNotifyShortUuid(char.id);
        if (isNotifyHint || isNotifyFallback) {
          await _subscribe(qualified);
        } else if (char.isWritableWithResponse && _txChar == null) {
          _txChar = qualified;
        }
      }
      if (_txChar != null && _notify != null) return;
    }
  }

  Future<void> _subscribe(QualifiedCharacteristic qualified) async {
    await _notify?.cancel();
    _notify = _ble.subscribeToCharacteristic(qualified).listen(
        (data) => _incoming.add(String.fromCharCodes(data)));
  }

  @override
  Future<void> send(String command) async {
    final char = _txChar;
    if (char == null) return;
    await _ble.writeCharacteristicWithResponse(
        char, value: Uint8List.fromList('$command\r'.codeUnits));
  }

  @override
  Future<void> disconnect() async {
    await _notify?.cancel();
    await _connection?.cancel();
  }

  Uuid _parseUuid(String uuid) => Uuid.parse(uuid);
}

ObdTransport createBleTransport() => BleTransportMobile();
