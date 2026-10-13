import 'package:flutter/material.dart';
import '../component_steps/component_steps_page.dart';
import 'maintenance_schedule.dart';
import '../time_tracking/time_tracking.dart';

/// Tappable component summary card. Tapping it drills in to a full screen
/// page ([ComponentStepsPage]) with the component title, back arrow and steps.
class ComponentBlock extends StatelessWidget {
  final ComponentList component;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onCommitted;
  final ValueChanged<ComponentList> onComponentChanged;
  const ComponentBlock({super.key, required this.component, required this.onToggle, required this.onComponentChanged, this.onCommitted});

  void timerStart() => onComponentChanged(componentWithTimerStarted(component));
  void timerPause() => onComponentChanged(componentWithTimerPaused(component));
  void timerResume() => onComponentChanged(componentWithTimerResumed(component));
  void timerStop() => onComponentChanged(componentWithTimerStopped(component));
  void timerRestart() => onComponentChanged(componentWithTimerCleared(component));

  void openSteps(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ComponentStepsPage(
            component: component,
            onComponentChanged: onComponentChanged,
            onCommitted: onCommitted,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final incomplete = component.steps.any((s) => !s.done && !s.notApplicable);
    final isTracking = componentIsTracking(component);
    final isPaused = componentIsPaused(component);
    final hasRecord = componentHasTimerRecord(component);
    return Card(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      child: ListTile(
        onTap: () => openSteps(context),
        leading: Checkbox(value: !incomplete && component.steps.isNotEmpty, onChanged: (v) => onToggle(v ?? false)),
        title: Text(component.title),
        subtitle: Text('${component.steps.where((s) => s.done).length}/${component.steps.length}',
            style: TextStyle(color: incomplete ? Colors.red : Colors.green, fontWeight: FontWeight.w600)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          TimerButton(
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
          const Icon(Icons.chevron_right),
        ]),
      ),
    );
  }
}
