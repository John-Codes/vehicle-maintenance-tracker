import '../records/check_step.dart';
import 'maintenance_schedule.dart';

String todayDate() => DateTime.now().toIso8601String().split('T').first;

FrequencyList markFrequencyDone(FrequencyList list) => FrequencyList(
      lastDoneAt: todayDate(),
      components: list.components
          .map((c) => c.copyWith(steps: c.steps.map((s) => s.copyWith(done: true, notApplicable: false)).toList()))
          .toList(),
    );

FrequencyList clearFrequencyDone(FrequencyList list) => FrequencyList(
      lastDoneAt: '',
      components: list.components.map((c) => c.copyWith(steps: c.steps.map((s) => s.copyWith(done: false)).toList())).toList(),
    );

FrequencyList replaceStep(FrequencyList list, String componentId, CheckStep step) {
  final next = list.copyWith(
    components: list.components
        .map((c) => c.id == componentId ? c.copyWith(steps: c.steps.map((s) => s.id == step.id ? step : s).toList()) : c)
        .toList(),
  );
  final complete = next.components.every((c) => c.steps.isNotEmpty && c.steps.every((s) => s.done || s.notApplicable));
  return complete ? next : next.copyWith(lastDoneAt: '');
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

FrequencyList markComponentDone(FrequencyList list, String componentId, bool done) => list.copyWith(
      lastDoneAt: '',
      components: list.components.map((c) {
        if (c.id != componentId) return c;
        return c.copyWith(steps: c.steps.map((s) => s.copyWith(done: done, notApplicable: done ? false : s.notApplicable)).toList());
      }).toList(),
    );
