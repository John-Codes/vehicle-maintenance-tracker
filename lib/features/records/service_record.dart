import '../maintenance_lists/maintenance_schedule.dart';
import '../profile/technician.dart';

class ServiceRecord {
  final String id, vehicleNumber, serviceType, dateStarted, notes, nextSteps, vin, licensePlate;
  final num? miles, hours;
  final List<String> workerNames;
  final Technician technician;
  final MaintenanceSchedule schedule;
  const ServiceRecord({
    this.id = '',
    this.vehicleNumber = '',
    this.serviceType = '',
    required this.dateStarted,
    this.miles,
    this.hours,
    this.workerNames = const [],
    this.technician = const Technician(),
    this.schedule = const MaintenanceSchedule(daily: FrequencyList(), weekly: FrequencyList(), monthly: FrequencyList()),
    this.notes = '',
    this.nextSteps = '',
    this.vin = '',
    this.licensePlate = '',
  });
  factory ServiceRecord.fromJson(Map j) => ServiceRecord(
        id: j['id'] ?? '',
        vehicleNumber: j['vehicle_number'] ?? '',
        serviceType: j['service_type'] ?? '',
        dateStarted: j['date_started'] ?? '',
        miles: j['miles'],
        hours: j['hours'],
        notes: j['notes'] ?? '',
        nextSteps: j['next_steps'] ?? '',
        technician: Technician.fromJson(Map<String, dynamic>.from(j['technician'] ?? {})),
        workerNames: List<String>.from(j['worker_names'] ?? []),
        schedule: MaintenanceSchedule.fromJson(Map<String, dynamic>.from(j['schedule'] ?? {})),
        vin: j['vin'] ?? '',
        licensePlate: j['license_plate'] ?? '',
      );
  Map<String, dynamic> toJson() => {
        'vehicle_number': vehicleNumber,
        'service_type': serviceType,
        'date_started': dateStarted,
        'miles': miles,
        'hours': hours,
        'worker_names': workerNames,
        'technician': technician.toJson(),
        'schedule': schedule.toJson(),
        'notes': notes,
        'next_steps': nextSteps,
        'vin': vin,
        'license_plate': licensePlate,
      };
  ServiceRecord copyWith({
    String? vehicleNumber,
    String? serviceType,
    num? miles,
    num? hours,
    List<String>? workerNames,
    MaintenanceSchedule? schedule,
    String? notes,
    String? nextSteps,
    String? vin,
    String? licensePlate,
    Technician? technician,
  }) =>
      ServiceRecord(
        id: id,
        dateStarted: dateStarted,
        technician: technician ?? this.technician,
        vehicleNumber: vehicleNumber ?? this.vehicleNumber,
        serviceType: serviceType ?? this.serviceType,
        miles: miles ?? this.miles,
        hours: hours ?? this.hours,
        workerNames: workerNames ?? this.workerNames,
        schedule: schedule ?? this.schedule,
        notes: notes ?? this.notes,
        nextSteps: nextSteps ?? this.nextSteps,
        vin: vin ?? this.vin,
        licensePlate: licensePlate ?? this.licensePlate,
      );
}
