import '../records/check_step.dart';
import '../maintenance_lists/maintenance_schedule.dart';

String nowIso() => DateTime.now().toIso8601String();

int elapsedSeconds(String startedAt) {
  if (startedAt.isEmpty) return 0;
  final start = DateTime.tryParse(startedAt);
  if (start == null) return 0;
  return DateTime.now().difference(start).inSeconds;
}

String describeSpent(int seconds) {
  if (seconds < 60) return '${seconds}s';
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return s > 0 ? '${m}m ${s}s' : '${m}m';
}

bool stepIsTracking(CheckStep step) => !step.done && !step.notApplicable && step.timeStartedAt.isNotEmpty && step.timerPausedAt.isEmpty;

bool stepIsPaused(CheckStep step) => step.timerPausedAt.isNotEmpty;

bool stepHasTimerRecord(CheckStep step) => step.timeStartedAt.isNotEmpty || step.timeSpentSeconds > 0 || step.timerPausedAt.isNotEmpty;

bool stepCanStart(CheckStep step) => !step.done && !step.notApplicable && step.timeStartedAt.isEmpty && step.timerPausedAt.isEmpty && step.timeSpentSeconds == 0;

CheckStep stepWithTimerStarted(CheckStep step) => step.copyWith(timeStartedAt: nowIso(), timeSpentSeconds: 0, timerPausedAt: '');

CheckStep stepWithTimerPaused(CheckStep step) {
  final spent = step.timeSpentSeconds + elapsedSeconds(step.timeStartedAt);
  return step.copyWith(timeStartedAt: '', timeSpentSeconds: spent, timerPausedAt: nowIso());
}

CheckStep stepWithTimerResumed(CheckStep step) => step.copyWith(timeStartedAt: nowIso(), timerPausedAt: '');

CheckStep stepWithTimerStopped(CheckStep step) {
  final spent = step.timeSpentSeconds + (step.timeStartedAt.isNotEmpty ? elapsedSeconds(step.timeStartedAt) : 0);
  return step.copyWith(timeStartedAt: '', timeSpentSeconds: spent, timerPausedAt: '');
}

CheckStep stepWithTimerCleared(CheckStep step) => step.copyWith(timeStartedAt: '', timeSpentSeconds: 0, timerPausedAt: '');

bool componentIsTracking(ComponentList component) => component.timeStartedAt.isNotEmpty && component.timerPausedAt.isEmpty;

bool componentIsPaused(ComponentList component) => component.timerPausedAt.isNotEmpty;

bool componentHasTimerRecord(ComponentList component) => component.timeStartedAt.isNotEmpty || component.timeSpentSeconds > 0 || component.timerPausedAt.isNotEmpty;

bool componentCanStart(ComponentList component) => component.timeStartedAt.isEmpty && component.timerPausedAt.isEmpty && component.timeSpentSeconds == 0;

ComponentList componentWithTimerStarted(ComponentList component) => component.copyWith(timeStartedAt: nowIso(), timeSpentSeconds: 0, timerPausedAt: '');

ComponentList componentWithTimerPaused(ComponentList component) {
  final spent = component.timeSpentSeconds + elapsedSeconds(component.timeStartedAt);
  return component.copyWith(timeStartedAt: '', timeSpentSeconds: spent, timerPausedAt: nowIso());
}

ComponentList componentWithTimerResumed(ComponentList component) => component.copyWith(timeStartedAt: nowIso(), timerPausedAt: '');

ComponentList componentWithTimerStopped(ComponentList component) {
  final spent = component.timeSpentSeconds + (component.timeStartedAt.isNotEmpty ? elapsedSeconds(component.timeStartedAt) : 0);
  return component.copyWith(timeStartedAt: '', timeSpentSeconds: spent, timerPausedAt: '');
}

ComponentList componentWithTimerCleared(ComponentList component) => component.copyWith(timeStartedAt: '', timeSpentSeconds: 0, timerPausedAt: '');

bool frequencyIsTracking(FrequencyList list) => list.timeStartedAt.isNotEmpty && list.timerPausedAt.isEmpty;

bool frequencyIsPaused(FrequencyList list) => list.timerPausedAt.isNotEmpty;

bool frequencyHasTimerRecord(FrequencyList list) => list.timeStartedAt.isNotEmpty || list.timeSpentSeconds > 0 || list.timerPausedAt.isNotEmpty;

bool frequencyCanStart(FrequencyList list) => list.timeStartedAt.isEmpty && list.timerPausedAt.isEmpty && list.timeSpentSeconds == 0;

FrequencyList frequencyWithTimerStarted(FrequencyList list) => list.copyWith(timeStartedAt: nowIso(), timeSpentSeconds: 0, timerPausedAt: '');

FrequencyList frequencyWithTimerPaused(FrequencyList list) {
  final spent = list.timeSpentSeconds + elapsedSeconds(list.timeStartedAt);
  return list.copyWith(timeStartedAt: '', timeSpentSeconds: spent, timerPausedAt: nowIso());
}

FrequencyList frequencyWithTimerResumed(FrequencyList list) => list.copyWith(timeStartedAt: nowIso(), timerPausedAt: '');

FrequencyList frequencyWithTimerStopped(FrequencyList list) {
  final spent = list.timeSpentSeconds + (list.timeStartedAt.isNotEmpty ? elapsedSeconds(list.timeStartedAt) : 0);
  return list.copyWith(timeStartedAt: '', timeSpentSeconds: spent, timerPausedAt: '');
}

FrequencyList frequencyWithTimerCleared(FrequencyList list) => list.copyWith(timeStartedAt: '', timeSpentSeconds: 0, timerPausedAt: '');