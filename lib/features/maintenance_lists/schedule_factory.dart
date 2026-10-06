import '../records/check_step.dart';
import 'maintenance_schedule.dart';

class ScheduleComponent {
  final String id;
  final String title;
  const ScheduleComponent(this.id, this.title);
}

class ScheduleTask {
  final String componentId;
  final String id;
  final String title;
  const ScheduleTask(this.componentId, this.id, this.title);
}

MaintenanceSchedule buildSchedule(List<ScheduleComponent> components, List<ScheduleTask> daily, List<ScheduleTask> weekly, List<ScheduleTask> monthly) {
  FrequencyList build(String prefix, List<ScheduleTask> tasks) => FrequencyList(components: [
        for (final component in components)
          ComponentList(
            id: component.id,
            title: component.title,
            steps: [
              for (final task in tasks)
                if (task.componentId == component.id) CheckStep(id: '$prefix-${task.id}', title: task.title),
            ],
          ),
      ]);
  return MaintenanceSchedule(daily: build('d', daily), weekly: build('w', weekly), monthly: build('m', monthly));
}
