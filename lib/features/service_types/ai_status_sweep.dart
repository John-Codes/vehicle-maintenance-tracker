import 'package:flutter/material.dart';

/// The fast colorful light that races across the AI pill, left to right.
class AiStatusSweep extends StatelessWidget {
  final AnimationController controller;
  const AiStatusSweep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => SlideTransition(
        position: controller.drive(Tween(
            begin: const Offset(-1.4, 0), end: const Offset(3.6, 0))),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.35,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color(0x001fddb9), Color(0x661fddb9),
                  Color(0xb3ffffff), Color(0x667ff5dc), Color(0x001fddb9),
                ]),
              ),
            ),
          ),
        ),
      );
}
