import 'package:flutter/material.dart';
import 'dart:async';
import 'time_tracker.dart';

class TimeTrackingTimerText extends StatefulWidget {
  final String startedAt;
  final int spentSeconds;
  final String pausedAt;
  final bool isTracking;
  final bool isPaused;
  final TextStyle? style;
  const TimeTrackingTimerText({super.key, required this.startedAt, required this.spentSeconds, required this.pausedAt, required this.isTracking, required this.isPaused, this.style});

  @override
  State<TimeTrackingTimerText> createState() => _TimeTrackingTimerTextState();
}

class _TimeTrackingTimerTextState extends State<TimeTrackingTimerText> {
  late Timer _timer;
  int _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _elapsed = _computeElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.isTracking) setState(() => _elapsed = _computeElapsed());
    });
  }

  @override
  void didUpdateWidget(covariant TimeTrackingTimerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _elapsed = _computeElapsed();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  int _computeElapsed() {
    if (widget.isPaused) return widget.spentSeconds;
    if (widget.isTracking) return widget.spentSeconds + elapsedSeconds(widget.startedAt);
    return widget.spentSeconds;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPaused) {
      return Text('Paused · ${describeSpent(widget.spentSeconds)}', style: widget.style ?? const TextStyle(fontSize: 12, color: Colors.orange));
    }
    if (widget.isTracking) {
      return Text(describeSpent(_elapsed), style: widget.style ?? const TextStyle(fontSize: 12, color: Colors.blue));
    }
    if (widget.spentSeconds > 0) {
      return Text('Took ${describeSpent(widget.spentSeconds)}', style: widget.style ?? const TextStyle(fontSize: 12, color: Colors.green));
    }
    return const SizedBox.shrink();
  }
}