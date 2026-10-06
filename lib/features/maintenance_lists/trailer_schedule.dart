import 'maintenance_schedule.dart';
import 'schedule_factory.dart';

MaintenanceSchedule trailerSchedule() => buildSchedule(
      const [
        ScheduleComponent('brakes', 'Brakes'),
        ScheduleComponent('lights', 'Lights'),
        ScheduleComponent('tires', 'Tires'),
        ScheduleComponent('frame', 'Frame'),
      ],
      const [
        ScheduleTask('brakes', 'check', 'Brake check'),
        ScheduleTask('lights', 'all', 'All lights'),
        ScheduleTask('tires', 'cond', 'Tread and condition'),
        ScheduleTask('frame', 'landing', 'Landing gear'),
      ],
      const [
        ScheduleTask('brakes', 'chambers', 'Chambers'),
        ScheduleTask('lights', 'lenses', 'Lenses and wiring'),
        ScheduleTask('tires', 'pressure', 'Pressure'),
        ScheduleTask('frame', 'pins', 'Pins and cracks'),
      ],
      const [
        ScheduleTask('brakes', 'adjust', 'Brake adjustment'),
        ScheduleTask('lights', 'sockets', 'Lamp sockets'),
        ScheduleTask('tires', 'tread', 'Tread measure'),
        ScheduleTask('frame', 'susp', 'Suspension and axles'),
      ],
    );
