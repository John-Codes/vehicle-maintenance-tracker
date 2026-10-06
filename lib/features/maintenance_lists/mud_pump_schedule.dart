import 'maintenance_schedule.dart';
import 'schedule_factory.dart';

MaintenanceSchedule mudPumpSchedule() => buildSchedule(
      const [
        ScheduleComponent('fluid_end', 'Fluid end'),
        ScheduleComponent('power_end', 'Power end'),
        ScheduleComponent('drive', 'Drive'),
      ],
      const [
        ScheduleTask('fluid_end', 'liners', 'Liners and pistons'),
        ScheduleTask('fluid_end', 'relief', 'Relief valve'),
        ScheduleTask('power_end', 'oil', 'Oil level'),
        ScheduleTask('drive', 'belts', 'Belts'),
      ],
      const [
        ScheduleTask('fluid_end', 'valves', 'Valves and seats'),
        ScheduleTask('power_end', 'wipers', 'Rod wipers'),
        ScheduleTask('drive', 'alignment', 'Sheave alignment'),
      ],
      const [
        ScheduleTask('fluid_end', 'strainer', 'Discharge strainer'),
        ScheduleTask('power_end', 'sump', 'Sump and oil'),
        ScheduleTask('drive', 'guards', 'Guards'),
      ],
    );
