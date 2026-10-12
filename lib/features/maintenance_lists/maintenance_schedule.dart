import '../records/check_step.dart';

/// Contract: daily, weekly, and monthly are always present.
/// Each list has last_done_at plus components. Components hold leaf steps only.
class ComponentList {
  final String id;
  final String title;
  final List<CheckStep> steps;
  final String timeStartedAt;
  final int timeSpentSeconds;
  final String timerPausedAt;
  const ComponentList({required this.id, required this.title, this.steps = const [], this.timeStartedAt = '', this.timeSpentSeconds = 0, this.timerPausedAt = ''});
  ComponentList copyWith({List<CheckStep>? steps, String? timeStartedAt, int? timeSpentSeconds, String? timerPausedAt}) => ComponentList(id: id, title: title, steps: steps ?? this.steps, timeStartedAt: timeStartedAt ?? this.timeStartedAt, timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds, timerPausedAt: timerPausedAt ?? this.timerPausedAt);
  factory ComponentList.fromJson(Map j) => ComponentList(
        id: '${j['id'] ?? ''}',
        title: '${j['title'] ?? ''}',
        steps: ((j['steps'] as List?) ?? []).map((x) => CheckStep.fromJson(Map<String, dynamic>.from(x))).toList(),
        timeStartedAt: '${j['time_started_at'] ?? ''}',
        timeSpentSeconds: ((j['time_spent_seconds'] as num?) ?? 0).toInt(),
        timerPausedAt: '${j['timer_paused_at'] ?? ''}',
      );
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'steps': steps.map((s) => s.toJson()).toList(), 'time_started_at': timeStartedAt, 'time_spent_seconds': timeSpentSeconds, 'timer_paused_at': timerPausedAt};
}

class FrequencyList {
  final String lastDoneAt;
  final List<ComponentList> components;
  final String timeStartedAt;
  final int timeSpentSeconds;
  final String timerPausedAt;
  const FrequencyList({this.lastDoneAt = '', this.components = const [], this.timeStartedAt = '', this.timeSpentSeconds = 0, this.timerPausedAt = ''});
  bool get markedDone => lastDoneAt.isNotEmpty;
  FrequencyList copyWith({String? lastDoneAt, List<ComponentList>? components, String? timeStartedAt, int? timeSpentSeconds, String? timerPausedAt}) =>
      FrequencyList(lastDoneAt: lastDoneAt ?? this.lastDoneAt, components: components ?? this.components, timeStartedAt: timeStartedAt ?? this.timeStartedAt, timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds, timerPausedAt: timerPausedAt ?? this.timerPausedAt);
  factory FrequencyList.fromJson(Map j) => FrequencyList(
        lastDoneAt: '${j['last_done_at'] ?? ''}',
        components: ((j['components'] as List?) ?? []).map((x) => ComponentList.fromJson(Map<String, dynamic>.from(x))).toList(),
        timeStartedAt: '${j['time_started_at'] ?? ''}',
        timeSpentSeconds: ((j['time_spent_seconds'] as num?) ?? 0).toInt(),
        timerPausedAt: '${j['timer_paused_at'] ?? ''}',
      );
  Map<String, dynamic> toJson() => {'last_done_at': lastDoneAt, 'components': components.map((c) => c.toJson()).toList(), 'time_started_at': timeStartedAt, 'time_spent_seconds': timeSpentSeconds, 'timer_paused_at': timerPausedAt};
}

class MaintenanceSchedule {
  final FrequencyList daily;
  final FrequencyList weekly;
  final FrequencyList monthly;
  const MaintenanceSchedule({required this.daily, required this.weekly, required this.monthly});
  factory MaintenanceSchedule.empty() => const MaintenanceSchedule(daily: FrequencyList(), weekly: FrequencyList(), monthly: FrequencyList());
  List<CheckStep> get leaves => [...daily.components, ...weekly.components, ...monthly.components].expand((c) => c.steps).toList();
  MaintenanceSchedule copyWith({FrequencyList? daily, FrequencyList? weekly, FrequencyList? monthly}) =>
      MaintenanceSchedule(daily: daily ?? this.daily, weekly: weekly ?? this.weekly, monthly: monthly ?? this.monthly);
  factory MaintenanceSchedule.fromJson(Map j) {
    for (final key in ['daily', 'weekly', 'monthly']) {
      if (j[key] is! Map) throw FormatException('schedule.$key is required');
    }
    return MaintenanceSchedule(
      daily: FrequencyList.fromJson(Map<String, dynamic>.from(j['daily'])),
      weekly: FrequencyList.fromJson(Map<String, dynamic>.from(j['weekly'])),
      monthly: FrequencyList.fromJson(Map<String, dynamic>.from(j['monthly'])),
    );
  }
  Map<String, dynamic> toJson() => {'daily': daily.toJson(), 'weekly': weekly.toJson(), 'monthly': monthly.toJson()};
}
