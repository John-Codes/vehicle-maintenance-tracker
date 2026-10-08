import '../checklist_history/step_done_logic.dart' show todayDate;
import '../records/check_step.dart';
import 'maintenance_schedule.dart';

FrequencyList replaceStep(FrequencyList list, String componentId, CheckStep step) {
  final next = list.copyWith(
    components: list.components
        .map((c) => c.id == componentId ? c.copyWith(steps: c.steps.map((s) => s.id == step.id ? step : s).toList()) : c)
        .toList(),
  );
  final complete = next.components.isNotEmpty &&
      next.components.every((c) => c.steps.isNotEmpty && c.steps.every((s) => s.done || s.notApplicable));
  return complete
      ? next.copyWith(lastDoneAt: next.lastDoneAt.isEmpty ? todayDate() : next.lastDoneAt)
      : next.copyWith(lastDoneAt: '');
}

FrequencyList deleteStep(FrequencyList list, String componentId, String stepId) => list.copyWith(
      components: list.components
          .map((c) => c.id == componentId ? c.copyWith(steps: c.steps.where((s) => s.id != stepId).toList()) : c)
          .toList(),
    );

FrequencyList addStep(FrequencyList list, String componentId) => list.copyWith(
      lastDoneAt: '',
      components: list.components.map((c) {
        if (c.id != componentId) return c;
        final step = CheckStep(id: DateTime.now().microsecondsSinceEpoch.toString(), title: 'New item');
        return c.copyWith(steps: [...c.steps, step]);
      }).toList(),
    );
