import '../maintenance_lists/maintenance_schedule.dart';
class ServiceType {
  final String id, name;
  final MaintenanceSchedule schedule;
  const ServiceType({this.id = '', required this.name, required this.schedule});
  factory ServiceType.fromJson(Map j) => ServiceType(id: j['id'], name: j['name'], schedule: MaintenanceSchedule.fromJson(j['schedule']));
  Map<String, dynamic> toJson() => {'name': name, 'schedule': schedule.toJson()};
}
