import 'records_repository.dart';
import 'service_record.dart';
import '../telemetry/elm327_engine.dart';
import '../telemetry/telemetry_reading.dart';
import '../telemetry/transports/ble_transport.dart';
import '../telemetry/vehicle_profile.dart';

/// The per-record update loop: every record owns its own dongle binding,
/// and syncing reads THIS record's scanner, connects, and updates its miles.
class ScanSync {
  final RecordsRepository _repo;
  ScanSync([RecordsRepository? repo]) : _repo = repo ?? RecordsRepository();

  /// Pair a discovered adapter to a record: writes the scanner binding onto
  /// the record and returns the updated record.
  Future<ServiceRecord> pair(ServiceRecord record, String deviceId) async {
    final scannerId = _scannerIdFromDeviceId(deviceId);
    final now = DateTime.now().toUtc().toIso8601String();
    return _repo.save(record.copyWith(scanner: {
      'id': scannerId,
      'device_id': deviceId,
      'kind': 'ble',
      'paired_at': now,
    }));
  }

  /// Connect to the record's own dongle, read odometer + hours, save back.
  Future<ServiceRecord> syncNow(ServiceRecord record) async {
    final transport = createBleTransport();
    final engine = Elm327Engine(transport);
    try {
      await transport.connect(record.scanner['device_id'] as String);
      final ok = await engine.initialize();
      if (!ok) {
        throw Exception('The adapter did not respond. Unplug it, '
            'turn the key to ON, and try again.');
      }
      final profile = VehicleProfile.forVehicle(record.vehicleNumber);
      final miles = await engine.readOdometer(profile, currentMiles: record.miles?.toDouble());
      final hours = await engine.readEngineHours();
      if (miles == null) {
        throw Exception('Could not read the mileage yet. Open the advanced '
            'view to calibrate this vehicle, or type the miles in.');
      }
      final now = DateTime.now().toUtc().toIso8601String();
      return _repo.save(record.copyWith(
          miles: miles,
          hours: hours ?? record.hours,
          scanner: {...record.scanner, 'last_synced_at': now}));
    } finally {
      await engine.close();
    }
  }

  /// Test-read during pairing; returns the reading or throws plain-English.
  Future<TelemetryReading> testRead(String deviceId, ServiceRecord record) async {
    final transport = createBleTransport();
    final engine = Elm327Engine(transport);
    try {
      await transport.connect(deviceId);
      if (!await engine.initialize()) {
        throw Exception('The adapter did not respond. Unplug it, turn the '
            'key to ON, and try again.');
      }
      final profile = VehicleProfile.forVehicle(record.vehicleNumber);
      final miles = await engine.readOdometer(profile, currentMiles: record.miles?.toDouble());
      final hours = await engine.readEngineHours();
      return TelemetryReading(
          odometerMi: miles ?? -1, engineHours: hours, capturedAt: DateTime.now(),
          sourceId: 'adapter');
    } finally {
      await engine.close();
    }
  }

  String _scannerIdFromDeviceId(String deviceId) => deviceId;
}
