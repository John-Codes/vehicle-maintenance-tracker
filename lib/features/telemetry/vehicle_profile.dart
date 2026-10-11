/// Per-vehicle-make PID quirks. New makes = one more entry here.
class VehicleProfile {
  final String make;
  final String model;
  final List<String> odometerPids;

  const VehicleProfile(this.make, this.model, this.odometerPids);

  static const unknown = VehicleProfile('Generic', 'any', ['22F190', '221102']);

  /// 2010-2015 Toyota Prius (Gen 3, CAN): candidate enhanced odometer PIDs,
  /// probed in order. Calibrate on the real car with the debug view.
  static const priusGen3 = VehicleProfile('Toyota', 'Prius 2010-2015', [
    '22F190', '221102', '2180', '22F002',
  ]);

  static VehicleProfile forVehicle(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('prius')) return priusGen3;
    return unknown;
  }
}
