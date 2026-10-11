import '../../core/api_client.dart';

class TelemetryReading {
  final String id, vehicleNumber, source, notes, capturedAt;
  final double odometerMi;
  final double? engineHours;

  const TelemetryReading({
    required this.id, required this.vehicleNumber, required this.source,
    required this.notes, required this.capturedAt, required this.odometerMi,
    this.engineHours,
  });

  factory TelemetryReading.fromJson(Map<String, dynamic> json) => TelemetryReading(
        id: (json['id'] ?? '').toString(),
        vehicleNumber: (json['vehicle_number'] ?? '').toString(),
        source: (json['source'] ?? 'manual').toString(),
        notes: (json['notes'] ?? '').toString(),
        capturedAt: (json['captured_at'] ?? '').toString(),
        odometerMi: (json['odometer_mi'] as num? ?? 0).toDouble(),
        engineHours: (json['engine_hours'] as num?)?.toDouble(),
      );

  String get capturedDay => capturedAt.split('T').first;
}

class TelemetryRepository {
  final ApiClient _api;
  TelemetryRepository([ApiClient? api]) : _api = api ?? ApiClient();

  Future<TelemetryReading> add({
    required String vehicleNumber,
    required double odometerMi,
    double? engineHours,
    String source = 'manual',
    String notes = '',
  }) async =>
      TelemetryReading.fromJson(Map<String, dynamic>.from(await _api.post('/telemetry', {
        'vehicle_number': vehicleNumber,
        'odometer_mi': odometerMi,
        'engine_hours': engineHours,
        'source': source,
        'notes': notes,
      })));

  Future<TelemetryReading?> latest(String vehicleNumber) async {
    try {
      return TelemetryReading.fromJson(Map<String, dynamic>.from(
          await _api.get('/telemetry/latest?vehicle=${Uri.encodeQueryComponent(vehicleNumber)}')));
    } catch (_) {
      return null;
    }
  }

  Future<List<TelemetryReading>> list({String vehicle = ''}) async {
    final path = vehicle.trim().isEmpty
        ? '/telemetry'
        : '/telemetry?vehicle=${Uri.encodeQueryComponent(vehicle.trim())}';
    return (await _api.get(path) as List)
        .map((x) => TelemetryReading.fromJson(Map<String, dynamic>.from(x)))
        .toList();
  }
}
