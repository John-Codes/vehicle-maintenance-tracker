import 'maintenance_schedule.dart';
import 'schedule_factory.dart';

MaintenanceSchedule vermeerDrillsSchedule() => buildSchedule(
      const [
        ScheduleComponent('safety', 'Safety and controls'),
        ScheduleComponent('engine', 'Engine and cooling'),
        ScheduleComponent('hydraulic', 'Hydraulic system'),
        ScheduleComponent('drill', 'Drill head and tooling'),
        ScheduleComponent('rods', 'Rod handling and vise'),
        ScheduleComponent('carriage', 'Carriage, tracks, and frame'),
      ],
      const [
        ScheduleTask('safety', 'estop', 'E-stop, alarms, interlocks, and operator controls'),
        ScheduleTask('engine', 'levels', 'Engine oil, coolant, and fuel levels'),
        ScheduleTask('hydraulic', 'leaks', 'Hydraulic oil level, hoses, and leaks'),
        ScheduleTask('drill', 'head', 'Drill head, bit, and fluid swivel condition'),
        ScheduleTask('rods', 'vise', 'Vise jaws, rod clamps, and thread condition'),
        ScheduleTask('carriage', 'walk', 'Carriage, tracks, guards, and access steps'),
      ],
      const [
        ScheduleTask('safety', 'function', 'Control function, warning lights, and fire extinguisher'),
        ScheduleTask('engine', 'filters', 'Air filter, belts, radiator, and battery'),
        ScheduleTask('hydraulic', 'hydraulic_filters', 'Hydraulic filter indicators, fittings, and cylinders'),
        ScheduleTask('drill', 'lubricate', 'Drill head, swivel, gearbox, and grease points'),
        ScheduleTask('rods', 'inspect', 'Rod threads, racks, clamps, and loading system'),
        ScheduleTask('carriage', 'pins', 'Carriage pins, rollers, track tension, and frame bolts'),
      ],
      const [
        ScheduleTask('safety', 'records', 'Safety inspection records and emergency plan'),
        ScheduleTask('engine', 'service', 'Engine, coolant, fuel, and emissions service intervals'),
        ScheduleTask('hydraulic', 'analysis', 'Hydraulic oil condition, pressure, and hose replacement plan'),
        ScheduleTask('drill', 'wear', 'Drill head, tooling, swivel seals, and gearbox wear'),
        ScheduleTask('rods', 'measure', 'Rod straightness, thread wear, and vise alignment'),
        ScheduleTask('carriage', 'structure', 'Frame welds, anchors, tracks, and corrosion inspection'),
      ],
    );
