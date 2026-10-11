/// One normalized reading from any scanner, no matter the transport.
class TelemetryReading {
  final double odometerMi;
  final double? engineHours;
  final DateTime capturedAt;
  final String sourceId;

  const TelemetryReading({
    required this.odometerMi,
    required this.capturedAt,
    required this.sourceId,
    this.engineHours,
  });

  factory TelemetryReading.manual(double odometerMi, [double? engineHours]) =>
      TelemetryReading(odometerMi: odometerMi, engineHours: engineHours,
          capturedAt: DateTime.now(), sourceId: 'manual');
}
