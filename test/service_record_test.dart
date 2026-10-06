import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_maintenance_tracker/features/maintenance_lists/maintenance_schedule.dart';
import 'package:vehicle_maintenance_tracker/features/records/check_step.dart';
import 'package:vehicle_maintenance_tracker/features/records/service_record.dart';

void main() {
  test('schedule JSON keeps daily checklist values', () {
    final record = ServiceRecord(
      dateStarted: '2026-07-26',
      schedule: MaintenanceSchedule(
        daily: FrequencyList(components: [ComponentList(id: 'engine', title: 'Engine', steps: const [CheckStep(id: 'b', title: 'Brakes', done: true, value: 'Good')])]),
        weekly: const FrequencyList(),
        monthly: const FrequencyList(),
      ),
    );
    final loaded = ServiceRecord.fromJson(record.toJson());
    expect(loaded.schedule.daily.components.single.steps.single.done, isTrue);
    expect(loaded.schedule.daily.components.single.steps.single.value, 'Good');
    expect(loaded.schedule.weekly.components, isEmpty);
  });
}
