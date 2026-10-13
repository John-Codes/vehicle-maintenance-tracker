// Picks the BLE transport for the current platform: native gets the real
// adapter (flutter_reactive_ble); unsupported platforms get the stub.
import 'ble_transport_stub.dart' if (dart.library.io) 'ble_transport_mobile.dart' as impl;

import 'obd_transport.dart';

export 'obd_transport.dart';

ObdTransport createBleTransport() => impl.createBleTransport();
