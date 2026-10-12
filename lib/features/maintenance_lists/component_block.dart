import 'package:flutter/material.dart';
import '../editor/step_tile.dart';
import '../records/check_step.dart';
import 'maintenance_schedule.dart';
import '../time_tracking/time_tracking.dart';

class ComponentBlock extends StatelessWidget {
  final ComponentList component;
  final ValueChanged<CheckStep> onStep;
  final ValueChanged<String> onDelete;
  final VoidCallback onAdd;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onCommitted;
  final ValueChanged<ComponentList> onComponentChanged;
  const ComponentBlock({super.key, required this.component, required this.onStep, required this.onDelete, required this.onAdd, required this.onToggle, required this.onComponentChanged, this.onCommitted});

  void timerStart() => onComponentChanged(componentWithTimerStarted(component));
  void timerPause() => onComponentChanged(componentWithTimerPaused(component));
  void timerResume() => onComponentChanged(componentWithTimerResumed(component));
  void timerStop() => onComponentChanged(componentWithTimerStopped(component));
  void timerRestart() => onComponentChanged(componentWithTimerCleared(component));

  @override
  Widget build(BuildContext context) {
    final incomplete = component.steps.any((s) => !s.done && !s.notApplicable);
    final isTracking = componentIsTracking(component);
    final isPaused = componentIsPaused(component);
    final hasRecord = componentHasTimerRecord(component);
    return Card(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      child: ExpansionTile(
        leading: Checkbox(value: !incomplete && component.steps.isNotEmpty, onChanged: (v) => onToggle(v ?? false)),
        title: Text(component.title),
        subtitle: Text('${component.steps.where((s) => s.done).length}/${component.steps.length}',
            style: TextStyle(color: incomplete ? Colors.red : Colors.green, fontWeight: FontWeight.w600)),
        trailing: TimerButton(
          isTracking: isTracking,
          isPaused: isPaused,
          hasRecord: hasRecord,
          onStart: timerStart,
          onPause: timerPause,
          onResume: timerResume,
          onStop: timerStop,
          onRestart: timerRestart,
          startedAt: component.timeStartedAt,
          spentSeconds: component.timeSpentSeconds,
          pausedAt: component.timerPausedAt,
        ),
        children: [
          for (final step in component.steps)
            StepTile(step: step, onChanged: onStep, onDelete: () => onDelete(step.id), onCommitted: onCommitted),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add item')),
          ),
        ],
      ),
    );
  }
}
