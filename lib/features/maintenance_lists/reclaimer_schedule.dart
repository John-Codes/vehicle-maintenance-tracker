import 'maintenance_schedule.dart';
import 'schedule_factory.dart';

MaintenanceSchedule reclaimerSchedule() => buildSchedule(
      const [
        ScheduleComponent('electrical', 'Electrical'),
        ScheduleComponent('engine', 'Engine'),
        ScheduleComponent('pumps', 'Pumps'),
      ],
      const [
        ScheduleTask('electrical', 'estop', 'E-stops'),
        ScheduleTask('electrical', 'controls', 'Controls'),
        ScheduleTask('electrical', 'lights', 'Lights'),
        ScheduleTask('engine', 'oil', 'Oil level'),
        ScheduleTask('engine', 'coolant', 'Coolant'),
        ScheduleTask('engine', 'leaks', 'Leaks'),
        ScheduleTask('pumps', 'seals', 'Seal leaks'),
        ScheduleTask('pumps', 'gear', 'Gear oil'),
        ScheduleTask('pumps', 'relief', 'Relief valve'),
      ],
      const [
        ScheduleTask('electrical', 'battery', 'Battery terminals'),
        ScheduleTask('engine', 'air', 'Air filter'),
        ScheduleTask('engine', 'fuel', 'Fuel filter'),
        ScheduleTask('pumps', 'cones', 'Cone wear'),
        ScheduleTask('pumps', 'packing', 'Packing'),
      ],
      const [
        ScheduleTask('electrical', 'panel', 'Panel and wiring'),
        ScheduleTask('engine', 'service', 'Oil and filters'),
        ScheduleTask('pumps', 'strainer', 'Strainer and studs'),
      ],
    );
