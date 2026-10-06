import '../records/check_step.dart';
import 'maintenance_schedule.dart';

class ScheduleChecklistRow {
  final String item;
  final CheckStep step;
  const ScheduleChecklistRow(this.item, this.step);
}

List<ScheduleChecklistRow> scheduleChecklist(MaintenanceSchedule schedule) {
  final rows = <ScheduleChecklistRow>[];
  void add(String frequency, FrequencyList list) {
    for (final component in list.components) {
      for (final step in component.steps) {
        rows.add(ScheduleChecklistRow('$frequency · ${component.title} · ${step.title}', step));
      }
    }
  }
  add('Daily', schedule.daily);
  add('Weekly', schedule.weekly);
  add('Monthly', schedule.monthly);
  return rows;
}
