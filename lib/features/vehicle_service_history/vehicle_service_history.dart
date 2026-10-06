import '../maintenance_lists/schedule_checklist.dart';
import '../records/check_step.dart';
import '../records/service_record.dart';

class LastServiceInfo {
  final bool hasLastService;
  final String lastServiceDate;
  final List<CheckStep> lastServiceSteps;
  const LastServiceInfo(this.hasLastService, {this.lastServiceDate = '', this.lastServiceSteps = const []});
}

class VehicleServiceHistory {
  static LastServiceInfo findLastServiceForUnit(List<ServiceRecord> allRecords, String vehicleNumber) {
    if (allRecords.isEmpty || vehicleNumber.trim().isEmpty) return const LastServiceInfo(false);
    final unit = vehicleNumber.trim().toLowerCase();
    for (final record in allRecords) {
      if (record.vehicleNumber.trim().toLowerCase() != unit) continue;
      final steps = scheduleChecklist(record.schedule).map((row) => row.step.copyWith(title: row.item)).toList();
      return LastServiceInfo(true, lastServiceDate: record.dateStarted, lastServiceSteps: steps);
    }
    return const LastServiceInfo(false);
  }
}
