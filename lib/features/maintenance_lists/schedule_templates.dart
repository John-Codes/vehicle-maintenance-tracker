import 'maintenance_schedule.dart';
import 'mud_pump_schedule.dart';
import 'other_schedule.dart';
import 'reclaimer_schedule.dart';
import 'semi_schedule.dart';
import 'trailer_schedule.dart';
import 'vermeer_drills_schedule.dart';

class ScheduleTemplates {
  static List<String> types() => ['Semi', 'Trailer', 'Vermeer Reclaimer', 'Vermeer Drills', 'Mud Pump', 'Other'];
  static MaintenanceSchedule forType(String type) {
    switch (type) {
      case 'Semi':
        return semiSchedule();
      case 'Trailer':
        return trailerSchedule();
      case 'Vermeer Reclaimer':
        return reclaimerSchedule();
      case 'Vermeer Drills':
        return vermeerDrillsSchedule();
      case 'Mud Pump':
        return mudPumpSchedule();
      default:
        return otherSchedule();
    }
  }
}
