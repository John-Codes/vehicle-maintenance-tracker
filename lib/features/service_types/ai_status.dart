import 'dart:async';

import 'package:flutter/material.dart';

/// App-wide "AI is working" state. Null = idle; non-null while a checklist
/// generation runs in the background.
class AiJob {
  final String label;
  final DateTime startedAt;

  AiJob(this.label) : startedAt = DateTime.now();

  String get elapsed {
    final seconds = DateTime.now().difference(startedAt).inSeconds;
    final minutes = seconds ~/ 60;
    if (minutes >= 1) return '${minutes}m ${seconds % 60}s';
    return '$seconds s';
  }
}

final aiStatusNotifier = ValueNotifier<AiJob?>(null);

/// Subtle floating pill: "AI is working for you… (1m 20s)". Mounted once in
/// the app builder so it shows on every page; IgnorePointer means it can
/// never block a tap.
class AiStatusPill extends StatefulWidget {
  const AiStatusPill({super.key});
  @override
  State<AiStatusPill> createState() => _AiStatusPillState();
}

class _AiStatusPillState extends State<AiStatusPill> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<AiJob?>(
        valueListenable: aiStatusNotifier,
        builder: (context, job, child) => IgnorePointer(
          child: AnimatedSlide(
            offset: job == null ? const Offset(0, 1.6) : Offset.zero,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 88),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xff0b7c66),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 10)],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
                  const SizedBox(width: 10),
                  Text('AI is working for you… (${job?.elapsed ?? ""})',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
        ),
      );
}
