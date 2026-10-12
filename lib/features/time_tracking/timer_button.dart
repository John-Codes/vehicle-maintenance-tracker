import 'package:flutter/material.dart';
import 'time_tracking_timer_text.dart';

class TimerButton extends StatelessWidget {
  final bool isTracking;
  final bool isPaused;
  final bool hasRecord;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onRestart;
  final String startedAt;
  final int spentSeconds;
  final String pausedAt;
  final TextStyle? textStyle;
  const TimerButton({super.key, required this.isTracking, required this.isPaused, required this.hasRecord, required this.onStart, required this.onPause, required this.onResume, required this.onStop, required this.onRestart, required this.startedAt, required this.spentSeconds, required this.pausedAt, this.textStyle});

  @override
  Widget build(BuildContext context) {
    if (hasRecord && !isTracking && !isPaused) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        TimeTrackingTimerText(startedAt: startedAt, spentSeconds: spentSeconds, pausedAt: pausedAt, isTracking: false, isPaused: false, style: textStyle),
        const SizedBox(width: 8),
        IconButton(icon: const Icon(Icons.restart_alt), tooltip: 'Delete time and restart', onPressed: onRestart),
      ]);
    }
    if (isTracking || isPaused) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        TimeTrackingTimerText(startedAt: startedAt, spentSeconds: spentSeconds, pausedAt: pausedAt, isTracking: isTracking, isPaused: isPaused, style: textStyle),
        const SizedBox(width: 8),
        if (isTracking) IconButton(icon: const Icon(Icons.pause), tooltip: 'Pause', onPressed: onPause),
        if (isPaused) IconButton(icon: const Icon(Icons.play_arrow), tooltip: 'Resume', onPressed: onResume),
        const SizedBox(width: 4),
        IconButton(icon: const Icon(Icons.stop), tooltip: 'Stop and record time', onPressed: onStop),
      ]);
    }
    return IconButton(icon: const Icon(Icons.timer), tooltip: 'Start timer', onPressed: onStart);
  }
}