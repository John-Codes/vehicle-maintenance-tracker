import 'maintenance_schedule.dart';
import 'schedule_factory.dart';

MaintenanceSchedule otherSchedule() => buildSchedule(
      const [
        ScheduleComponent('safety', 'Safety and controls'),
        ScheduleComponent('fluids', 'Fluids and leaks'),
        ScheduleComponent('power', 'Engine, battery, or power source'),
        ScheduleComponent('structure', 'Structure, guards, and fasteners'),
        ScheduleComponent('running', 'Wheels, tracks, brakes, or steering'),
      ],
      const [
        ScheduleTask('safety', 'controls', 'Controls, alarms, emergency stop, and PPE'),
        ScheduleTask('fluids', 'leaks', 'Fluid levels, leaks, and hose condition'),
        ScheduleTask('power', 'start', 'Starting system, battery, and warning lights'),
        ScheduleTask('structure', 'walk', 'Guards, fasteners, damage, and corrosion'),
        ScheduleTask('running', 'condition', 'Wheels, tracks, brakes, and steering condition'),
      ],
      const [
        ScheduleTask('safety', 'test', 'Safety devices and operational function test'),
        ScheduleTask('fluids', 'service', 'Lubrication points, filters, and service indicators'),
        ScheduleTask('power', 'belts', 'Belts, cables, connectors, and cooling system'),
        ScheduleTask('structure', 'torque', 'Critical fasteners, mounts, and welds'),
        ScheduleTask('running', 'lubricate', 'Hubs, pivots, suspension, and tire or track pressure'),
      ],
      const [
        ScheduleTask('safety', 'records', 'Inspection records, labels, and replacement planning'),
        ScheduleTask('fluids', 'analysis', 'Fluid condition, analysis, and scheduled replacement'),
        ScheduleTask('power', 'service', 'Power source, filters, cooling, and exhaust service'),
        ScheduleTask('structure', 'inspect', 'Structural inspection and corrosion repair plan'),
        ScheduleTask('running', 'measure', 'Wear measurements, alignment, and brake service'),
      ],
    );
