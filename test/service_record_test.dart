import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_maintenance_tracker/features/records/check_step.dart';
import 'package:vehicle_maintenance_tracker/features/records/service_record.dart';

void main() {
  test('record JSON keeps checklist values', () {
    final record = ServiceRecord(dateStarted: '2026-07-26', steps: const [CheckStep(id: 'b', title: 'Brakes', done: true, value: 'Good')]);
    final loaded = ServiceRecord.fromJson(record.toJson());
    expect(loaded.steps.single.done, isTrue);
    expect(loaded.steps.single.value, 'Good');
  });
}
