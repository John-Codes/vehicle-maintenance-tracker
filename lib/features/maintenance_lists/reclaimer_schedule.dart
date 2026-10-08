import 'maintenance_schedule.dart';
import 'schedule_factory.dart';

MaintenanceSchedule reclaimerSchedule() => buildSchedule(
      const [
        ScheduleComponent('electrical', 'Electrical'),
        ScheduleComponent('engine', 'Engine'),
        ScheduleComponent('pumps', 'Pumps'),
        ScheduleComponent('hydraulic', 'Hydraulic system'),
        ScheduleComponent('rotor', 'Rotor and cutting system'),
        ScheduleComponent('conveyor', 'Conveyor and material system'),
        ScheduleComponent('frame', 'Frame, guards, and running gear'),
      ],
      const [
        ScheduleTask('electrical', 'estop', 'E-stops and safety interlocks'),
        ScheduleTask('electrical', 'controls', 'Controls, alarms, and display'),
        ScheduleTask('electrical', 'lights', 'Work lights and warning beacons'),
        ScheduleTask('engine', 'oil', 'Engine oil and coolant levels'),
        ScheduleTask('engine', 'coolant', 'Radiator, hoses, and air intake'),
        ScheduleTask('engine', 'leaks', 'Fuel, oil, coolant, and exhaust leaks'),
        ScheduleTask('pumps', 'seals', 'Pump seals, hoses, and fittings'),
        ScheduleTask('hydraulic', 'level', 'Hydraulic oil level and leaks'),
        ScheduleTask('rotor', 'guards', 'Rotor guards, teeth, and fasteners'),
        ScheduleTask('conveyor', 'conveyor_walk', 'Conveyor belt, rollers, and discharge area'),
        ScheduleTask('frame', 'frame_walk', 'Frame, tracks or tires, and access steps'),
      ],
      const [
        ScheduleTask('electrical', 'battery', 'Battery terminals and charging system'),
        ScheduleTask('engine', 'filters', 'Air, fuel, and oil filter indicators'),
        ScheduleTask('engine', 'belts', 'Belts, tensioners, mounts, and exhaust'),
        ScheduleTask('pumps', 'packing', 'Packing, bearings, and pump vibration'),
        ScheduleTask('hydraulic', 'hydraulic_filters', 'Hydraulic filters, hoses, and relief settings'),
        ScheduleTask('rotor', 'wear', 'Rotor tooth wear, holders, and shaft play'),
        ScheduleTask('conveyor', 'alignment', 'Belt tracking, tension, and scrapers'),
        ScheduleTask('frame', 'lube', 'Grease points, pins, bushings, and fasteners'),
      ],
      const [
        ScheduleTask('electrical', 'panel', 'Panel, wiring, sensors, and fault history'),
        ScheduleTask('engine', 'engine_service', 'Oil, filters, coolant, and emissions service'),
        ScheduleTask('pumps', 'pump_service', 'Pump alignment, seals, and pressure test'),
        ScheduleTask('hydraulic', 'hydraulic_service', 'Hydraulic oil analysis and hose replacement plan'),
        ScheduleTask('rotor', 'measure', 'Rotor balance, wear limits, and guard condition'),
        ScheduleTask('conveyor', 'bearings', 'Conveyor bearings, rollers, and structure'),
        ScheduleTask('frame', 'frame_structure', 'Frame welds, tracks or tires, and corrosion'),
      ],
    );
