import 'package:flutter/foundation.dart';
import '../maintenance_lists/maintenance_schedule.dart';
import '../records/check_step.dart';
import 'location_capture.dart';
import 'step_done_logic.dart';

/// One-call entry points for the checklist done logic: capture the location,
/// apply the transition and let the editor persist the result.
class ChecklistHistory {
  const ChecklistHistory._();

  static Future<void> toggleStep({required CheckStep step, required bool done, required ValueChanged<CheckStep> onChanged, VoidCallback? onCommitted}) async {
    if (done == step.done) return;
    final fix = done ? await captureLocation() : null;
    onChanged(stepTransition(step, done, fix));
    onCommitted?.call();
  }

  static Future<void> toggleComponent({required FrequencyList list, required String componentId, required bool done, required ValueChanged<FrequencyList> write, required VoidCallback onCommitted}) async {
    final fix = done ? await captureLocation() : null;
    write(componentMarked(list, componentId, done, fix));
    onCommitted();
  }

  static Future<void> markFrequency({required FrequencyList list, required ValueChanged<FrequencyList> write, required VoidCallback onCommitted}) async {
    final fix = await captureLocation();
    write(frequencyMarked(list, fix));
    onCommitted();
  }

  static void clearFrequency({required FrequencyList list, required ValueChanged<FrequencyList> write, required VoidCallback onCommitted}) {
    write(frequencyCleared(list));
    onCommitted();
  }
}
