import 'maintenance_schedule.dart';
import 'schedule_factory.dart';

MaintenanceSchedule semiSchedule() => buildSchedule(
      const [
        ScheduleComponent('brakes', 'Brakes'),
        ScheduleComponent('lights', 'Lights'),
        ScheduleComponent('tires', 'Tires'),
        ScheduleComponent('fluids', 'Fluids'),
      ],
      const [
        ScheduleTask('brakes', 'check', 'Brake check'),
        ScheduleTask('lights', 'all', 'All lights'),
        ScheduleTask('tires', 'cond', 'Tread and condition'),
        ScheduleTask('fluids', 'leaks', 'Leaks'),
      ],
      const [
        ScheduleTask('brakes', 'adjusters', 'Slack adjusters'),
        ScheduleTask('lights', 'lenses', 'Lenses and wiring'),
        ScheduleTask('tires', 'pressure', 'Pressure'),
        ScheduleTask('fluids', 'def', 'DEF level'),
      ],
      const [
        ScheduleTask('brakes', 'adjust', 'Brake adjustment'),
        ScheduleTask('lights', 'sockets', 'Lamp sockets'),
        ScheduleTask('tires', 'tread', 'Tread measure'),
        ScheduleTask('fluids', 'filters', 'Filter service'),
      ],
    );
