import 'dart:async';

import 'package:flutter/material.dart';

import 'ai_status_sweep.dart';

/// App-wide "AI is working" state (null = idle).
class AiJob {
  final String label;
  final DateTime startedAt;

  AiJob(this.label) : startedAt = DateTime.now();

  String get elapsed {
    final seconds = DateTime.now().difference(startedAt).inSeconds;
    return seconds >= 60 ? '${seconds ~/ 60}m ${seconds % 60}s' : '$seconds s';
  }
}

final aiStatusNotifier = ValueNotifier<AiJob?>(null);

/// Pill floating above the bottom nav: small text, sparkle icon, and a
/// fast colorful sweep. Never blocks taps (IgnorePointer).
class AiStatusPill extends StatefulWidget {
  const AiStatusPill({super.key});
  @override
  State<AiStatusPill> createState() => _AiStatusPillState();
}

class _AiStatusPillState extends State<AiStatusPill>
    with SingleTickerProviderStateMixin {
  late final _sweep = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1250))
    ..repeat();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _sweep.dispose();
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<AiJob?>(
        valueListenable: aiStatusNotifier,
        builder: (context, job, child) => IgnorePointer(
          child: AnimatedSlide(
            offset: job == null ? const Offset(0, 2) : Offset.zero,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            child: Align(
              alignment: Alignment.bottomCenter,
              // Material wrapper: gives the text a proper style and kills
              // Flutter's raw-text yellow underline.
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 86),
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(colors: [
                      Color(0xff0f1c49), Color(0xff0b7c66)
                    ]),
                    boxShadow: const [
                      BoxShadow(color: Color(0x4d1fddb9), blurRadius: 14, spreadRadius: -3)
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(children: [
                      Positioned.fill(child: AiStatusSweep(controller: _sweep)),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.auto_awesome,
                            size: 14, color: Color(0xff7ff5dc)),
                        const SizedBox(width: 7),
                        Text(
                          'AI is gathering maintenance information… ${job?.elapsed ?? ""}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.2),
                        ),
                      ]),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
