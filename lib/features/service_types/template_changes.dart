import '../maintenance_lists/maintenance_schedule.dart';
MaintenanceSchedule changeComponents(MaintenanceSchedule schedule, String id, String? title) {
  FrequencyList change(FrequencyList f) => f.copyWith(components: [
    for (final c in f.components) if (c.id != id) c else if (title != null) ComponentList(id: id, title: title, steps: c.steps),
    if (title != null && !f.components.any((c) => c.id == id)) ComponentList(id: id, title: title),
  ]);
  return MaintenanceSchedule(daily: change(schedule.daily), weekly: change(schedule.weekly), monthly: change(schedule.monthly));
}
MaintenanceSchedule freshTemplate(MaintenanceSchedule schedule) {
  FrequencyList fresh(FrequencyList f) => FrequencyList(components: [for (final c in f.components)
    c.copyWith(steps: [for (final s in c.steps) s.copyWith(done: false, notApplicable: false, doneAt: '', doneHistory: const [])])]);
  return MaintenanceSchedule(daily: fresh(schedule.daily), weekly: fresh(schedule.weekly), monthly: fresh(schedule.monthly));
}
