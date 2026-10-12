import 'package:flutter/material.dart';
import '../../core/large_display.dart';
import '../checklist_history/checklist_history.dart';
import '../records/check_step.dart';
import '../time_tracking/time_tracking.dart';

class StepTile extends StatefulWidget {
  final CheckStep step;
  final ValueChanged<CheckStep> onChanged;
  final VoidCallback onDelete;
  final VoidCallback? onCommitted;
  const StepTile({super.key, required this.step, required this.onChanged, required this.onDelete, this.onCommitted});
  @override State<StepTile> createState() => _StepTileState();
}

class _StepTileState extends State<StepTile> {
  late final title = TextEditingController(text: widget.step.title);
  late final value = TextEditingController(text: widget.step.value);
  late final notes = TextEditingController(text: widget.step.notes);
  @override void dispose() { title.dispose(); value.dispose(); notes.dispose(); super.dispose(); }
  CheckStep withText() => widget.step.copyWith(title: title.text, value: value.text, notes: notes.text);
  void change({bool? d, bool? na}) { final n = na ?? widget.step.notApplicable; final dn = n ? false : (d ?? widget.step.done); widget.onChanged(withText().copyWith(done: dn, notApplicable: n)); if (d != null || na != null) widget.onCommitted?.call(); }
  void toggle(bool d) => ChecklistHistory.toggleStep(step: withText(), done: d, onChanged: widget.onChanged, onCommitted: widget.onCommitted);
  void info() { if (widget.step.description.isEmpty) return; showDialog(context: context, builder: (_) => AlertDialog(title: Text(widget.step.title), content: Text(widget.step.description), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))])); }
  String stamp() { final iso = widget.step.doneAt; if (iso.isEmpty || !iso.contains('T')) return iso; final parts = iso.split('T'); return '${parts.first} ${parts.last.substring(0, 5)}'; }
  void timerStart() => widget.onChanged(stepWithTimerStarted(widget.step));
  void timerPause() => widget.onChanged(stepWithTimerPaused(widget.step));
  void timerResume() => widget.onChanged(stepWithTimerResumed(widget.step));
  void timerStop() => widget.onChanged(stepWithTimerStopped(widget.step));
  void timerRestart() => widget.onChanged(stepWithTimerCleared(widget.step));

  @override Widget build(BuildContext c) {
    final n = widget.step.notApplicable;
    final undone = !n && !widget.step.done;
    final big = biggerTextButtonsEnabled;
    final iconSize = big ? 26.0 : 24.0;
    final isTracking = stepIsTracking(widget.step);
    final isPaused = stepIsPaused(widget.step);
    final hasRecord = stepHasTimerRecord(widget.step);
    return Card(child: ExpansionTile(
      leading: Row(mainAxisSize: MainAxisSize.min, children: [
        Checkbox(value: n ? false : widget.step.done, onChanged: n ? null : (x) => toggle(x ?? false)),
        TextButton(onPressed: () => change(na: !n), style: TextButton.styleFrom(minimumSize: big ? const Size(64, 52) : null, padding: big ? const EdgeInsets.symmetric(horizontal: 14) : null), child: Text('N/A', style: TextStyle(fontSize: big ? 16 : 14, color: n ? Colors.orange : Colors.grey))),
      ]),
      title: Text(widget.step.title, style: TextStyle(decoration: n ? TextDecoration.lineThrough : null, color: n ? Colors.grey : (undone ? Colors.red : null))),
      subtitle: widget.step.doneAt.isEmpty ? null : Text('Done @ ${stamp()}', style: const TextStyle(fontSize: 12, color: Colors.green)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        TimerButton(isTracking: isTracking, isPaused: isPaused, hasRecord: hasRecord, onStart: timerStart, onPause: timerPause, onResume: timerResume, onStop: timerStop, onRestart: timerRestart, startedAt: widget.step.timeStartedAt, spentSeconds: widget.step.timeSpentSeconds, pausedAt: widget.step.timerPausedAt, textStyle: TextStyle(fontSize: big ? 12 : 10, fontWeight: FontWeight.w600)),
        if (widget.step.description.isNotEmpty) IconButton(icon: Icon(Icons.info_outline, size: iconSize), onPressed: info),
        IconButton(icon: Icon(Icons.delete_outline, size: iconSize), onPressed: widget.onDelete),
      ]),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        TextField(controller: title, enabled: !n, onChanged: (_) => change(), decoration: const InputDecoration(labelText: 'Title')),
        TextField(controller: value, enabled: !n, onChanged: (_) => change(), decoration: const InputDecoration(labelText: 'Location/Measurement/Readings')),
        TextField(controller: notes, enabled: !n, maxLines: 2, onChanged: (_) => change(), decoration: const InputDecoration(labelText: 'Notes')),
      ],
    ));
  }
}