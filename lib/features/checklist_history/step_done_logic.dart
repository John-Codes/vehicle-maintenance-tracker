import '../maintenance_lists/maintenance_schedule.dart';
import '../records/check_step.dart';
import 'done_event.dart';
import 'location_capture.dart';

String todayDate() => DateTime.now().toIso8601String().split('T').first;

/// Single step transition. History is append-only: an entry is written only
/// when the step changes to done, and unchecking never removes old entries.
CheckStep stepTransition(CheckStep step, bool done, LocationFix? fix) {
  final changed = done != step.done || (done && step.notApplicable);
  if (!changed) return step;
  if (!done) return step.copyWith(done: false, doneAt: '');
  final at = DateTime.now().toIso8601String();
  return step.copyWith(
    done: true,
    notApplicable: false,
    doneAt: at,
    doneHistory: [...step.doneHistory, DoneEvent(at: at, lat: fix?.lat, lng: fix?.lng, accuracy: fix?.accuracy)],
  );
}

FrequencyList frequencyMarked(FrequencyList list, LocationFix? fix) => FrequencyList(
      lastDoneAt: todayDate(),
      components: list.components.map((c) => c.copyWith(steps: c.steps.map((s) => stepTransition(s, true, fix)).toList())).toList(),
    );

FrequencyList frequencyCleared(FrequencyList list) => FrequencyList(
      lastDoneAt: '',
      components: list.components.map((c) => c.copyWith(steps: c.steps.map((s) => s.copyWith(done: false, doneAt: '')).toList())).toList(),
    );

FrequencyList componentMarked(FrequencyList list, String componentId, bool done, LocationFix? fix) {
  final components = list.components
      .map((c) => c.id == componentId ? c.copyWith(steps: c.steps.map((s) => stepTransition(s, done, fix)).toList()) : c)
      .toList();
  final complete = components.isNotEmpty &&
      components.every((c) => c.steps.isNotEmpty && c.steps.every((s) => s.done || s.notApplicable));
  return FrequencyList(lastDoneAt: complete ? todayDate() : '', components: components);
}
