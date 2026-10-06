import 'maintenance_schedule.dart';
import 'schedule_factory.dart';

MaintenanceSchedule otherSchedule() => buildSchedule(
      const [ScheduleComponent('general', 'General')],
      const [],
      const [],
      const [],
    );
