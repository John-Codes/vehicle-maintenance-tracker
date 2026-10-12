import 'package:flutter/material.dart';
import '../checklist_history/checklist_history.dart';
import '../time_tracking/time_tracking.dart';
import 'maintenance_schedule.dart';

class FrequencyRow extends StatelessWidget {
  final String id, label;
  final FrequencyList list;
  final bool open;
  final VoidCallback onTap;
  final ValueChanged<bool> onCheck;
  final ValueChanged<FrequencyList> onFrequencyChanged;
  const FrequencyRow({super.key, required this.id, required this.label, required this.list, required this.open, required this.onTap, required this.onCheck, required this.onFrequencyChanged});

  void timerStart() => onFrequencyChanged(frequencyWithTimerStarted(list));
  void timerPause() => onFrequencyChanged(frequencyWithTimerPaused(list));
  void timerResume() => onFrequencyChanged(frequencyWithTimerResumed(list));
  void timerStop() => onFrequencyChanged(frequencyWithTimerStopped(list));
  void timerRestart() => onFrequencyChanged(frequencyWithTimerCleared(list));

  @override
  Widget build(BuildContext context) {
    final due = isFrequencyDue(frequencyId: id, lastDoneAt: list.lastDoneAt);
    final last = list.lastDoneAt.isEmpty ? 'Never' : list.lastDoneAt.split('T').first;
    final isTracking = frequencyIsTracking(list);
    final isPaused = frequencyIsPaused(list);
    final hasRecord = frequencyHasTimerRecord(list);
    return ListTile(
      leading: Checkbox(value: !due, onChanged: (v) => onCheck(v ?? false)),
      title: Text(label),
      subtitle: Row(children: [
        Flexible(child: Text('Last done: $last')),
        const SizedBox(width: 8),
        DueBadge(due: due),
      ]),
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
          startedAt: list.timeStartedAt,
          spentSeconds: list.timeSpentSeconds,
          pausedAt: list.timerPausedAt,
        ),
        Icon(open ? Icons.expand_less : Icons.expand_more),
      ]),
      onTap: onTap,
    );
  }
}
