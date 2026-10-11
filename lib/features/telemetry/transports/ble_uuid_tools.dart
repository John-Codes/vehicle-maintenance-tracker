import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// BLE UUID helpers shared by transports: adapters advertise their 16-bit
/// alias either in byte slots 0-1 (short parse form) or 12-13 (spec form).
const notifyShortUuids = {0xfff2, 0x2362, 0x18f1};

int shortUuidOf(Uuid uuid) {
  final data = uuid.data;
  if (data.length >= 2 && (data[0] | data[1]) != 0) return (data[0] << 8) | data[1];
  if (data.length >= 14) return (data[12] << 8) | data[13];
  return 0;
}

bool isNotifyShortUuid(Uuid uuid) => notifyShortUuids.contains(shortUuidOf(uuid));
