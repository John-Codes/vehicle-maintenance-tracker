import '../checklist_history/done_event.dart';

class CheckStep {
  final String id;
  final String title;
  final String value;
  final String notes;
  final String description;
  final bool done;
  final bool notApplicable;
  final String doneAt;
  final List<DoneEvent> doneHistory;
  final String timeStartedAt;
  final int timeSpentSeconds;
  final String timerPausedAt;
  const CheckStep({required this.id, required this.title, this.value = '', this.notes = '', this.description = '', this.done = false, this.notApplicable = false, this.doneAt = '', this.doneHistory = const [], this.timeStartedAt = '', this.timeSpentSeconds = 0, this.timerPausedAt = ''});
  CheckStep copyWith({String? title, String? value, String? notes, String? description, bool? done, bool? notApplicable, String? doneAt, List<DoneEvent>? doneHistory, String? timeStartedAt, int? timeSpentSeconds, String? timerPausedAt}) => CheckStep(
      id: id,
      title: title ?? this.title,
      value: value ?? this.value,
      notes: notes ?? this.notes,
      description: description ?? this.description,
      done: done ?? this.done,
      notApplicable: notApplicable ?? this.notApplicable,
      doneAt: doneAt ?? this.doneAt,
      doneHistory: doneHistory ?? this.doneHistory,
      timeStartedAt: timeStartedAt ?? this.timeStartedAt,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      timerPausedAt: timerPausedAt ?? this.timerPausedAt);
  factory CheckStep.fromJson(Map j) => CheckStep(
      id: j['id'],
      title: j['title'],
      value: j['value'] ?? '',
      notes: j['notes'] ?? '',
      description: j['description'] ?? '',
      done: j['done'] ?? false,
      notApplicable: j['not_applicable'] ?? false,
      doneAt: j['done_at'] ?? '',
      doneHistory: ((j['done_history'] as List?) ?? []).map((x) => DoneEvent.fromJson(Map<String, dynamic>.from(x))).toList(),
      timeStartedAt: j['time_started_at'] ?? '',
      timeSpentSeconds: ((j['time_spent_seconds'] as num?) ?? 0).toInt(),
      timerPausedAt: j['timer_paused_at'] ?? '');
  Map toJson() => {'id': id, 'title': title, 'value': value, 'notes': notes, 'description': description, 'done': done, 'not_applicable': notApplicable, 'done_at': doneAt, 'done_history': doneHistory.map((e) => e.toJson()).toList(), 'time_started_at': timeStartedAt, 'time_spent_seconds': timeSpentSeconds, 'timer_paused_at': timerPausedAt};
}
