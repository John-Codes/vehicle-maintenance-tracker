/// The extension point for scanner compatibility: adding a new dongle brand
/// = one entry here (name pattern + BLE service UUIDs). All entries share
/// the same ELM327 engine; only radio details differ.
class ScannerRegistry {
  static const entries = [
    ScannerInfo(
      id: 'veepeak-ble',
      label: 'Veepeak OBDCheck (Bluetooth)',
      namePattern: r'(veepeak|obdcheck)',
      serviceUuids: _elm327BleServices,
    ),
    ScannerInfo(
      id: 'obdlink-ble',
      label: 'OBDLink (Bluetooth)',
      namePattern: r'(obdlink|scanlink)',
      serviceUuids: _elm327BleServices,
    ),
    ScannerInfo(
      id: 'vgate-ble',
      label: 'Vgate iCar Pro (Bluetooth)',
      namePattern: r'(vgate|icar)',
      serviceUuids: _elm327BleServices,
    ),
    ScannerInfo(
      id: 'lelink-ble',
      label: 'LELink (Bluetooth)',
      namePattern: r'(lelink)',
      serviceUuids: _elm327BleServices,
    ),
    ScannerInfo(
      id: 'generic-elm327',
      label: 'Generic ELM327 adapter (Bluetooth)',
      namePattern: r'(elm327|obd2|obdii|obd-ii)',
      serviceUuids: _elm327BleServices,
    ),
  ];

  /// The standard service UUIDs ELM327-over-BLE dongles advertise.
  static const _elm327BleServices = [
    'fff0', '18f0', 'ffe0', 'fff00000-0000-1000-8000-00805f9b34fb',
  ];

  static Iterable<String> get allServiceUuids =>
      entries.expand((entry) => entry.serviceUuids).toSet();

  static ScannerInfo? match(String deviceName) {
    final lower = deviceName.toLowerCase();
    for (final entry in entries) {
      if (RegExp(entry.namePattern).hasMatch(lower)) return entry;
    }
    return null;
  }

  static ScannerInfo byId(String id) =>
      entries.firstWhere((entry) => entry.id == id, orElse: () => entries.last);
}

class ScannerInfo {
  final String id;
  final String label;
  final String namePattern;
  final List<String> serviceUuids;

  const ScannerInfo({
    required this.id,
    required this.label,
    required this.namePattern,
    required this.serviceUuids,
  });
}
