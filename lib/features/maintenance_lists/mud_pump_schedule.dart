import 'maintenance_schedule.dart';
import 'schedule_factory.dart';

MaintenanceSchedule mudPumpSchedule() => buildSchedule(
      const [
        ScheduleComponent('fluid_end', 'Fluid end'),
        ScheduleComponent('power_end', 'Power end'),
        ScheduleComponent('drive', 'Drive'),
        ScheduleComponent('manifolds', 'Suction and discharge manifolds'),
        ScheduleComponent('safety', 'Relief, gauges, and guards'),
      ],
      const [
        ScheduleTask('fluid_end', 'liners', 'Liners, pistons, valves, and seats'),
        ScheduleTask('fluid_end', 'leaks', 'Fluid-end leaks and packing'),
        ScheduleTask('power_end', 'oil', 'Crankcase oil level and leaks'),
        ScheduleTask('drive', 'belts', 'Belts, guards, and abnormal vibration'),
        ScheduleTask('manifolds', 'hoses', 'Suction and discharge hoses, clamps, and fittings'),
        ScheduleTask('safety', 'gauge', 'Pressure gauges, relief valve, and emergency stop'),
      ],
      const [
        ScheduleTask('fluid_end', 'valves', 'Valve and seat wear inspection'),
        ScheduleTask('power_end', 'wipers', 'Rod wipers, crossheads, and guides'),
        ScheduleTask('drive', 'alignment', 'Sheave, coupling, and drive alignment'),
        ScheduleTask('manifolds', 'dampener', 'Pulsation dampener charge and manifold supports'),
        ScheduleTask('safety', 'fasteners', 'Guards, base bolts, and pressure relief test'),
      ],
      const [
        ScheduleTask('fluid_end', 'service', 'Liner, piston, valve, and seat service intervals'),
        ScheduleTask('power_end', 'sump', 'Sump, crankshaft, bearings, and oil analysis'),
        ScheduleTask('drive', 'guards', 'Drive guards, bearings, and fastener torque'),
        ScheduleTask('manifolds', 'manifold_service', 'Manifold, hose, strainer, and dampener service'),
        ScheduleTask('safety', 'safety_records', 'Pressure test records and inspection labels'),
      ],
    );
