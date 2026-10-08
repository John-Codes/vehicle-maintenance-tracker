import 'package:flutter/material.dart';

/// Red "Due" chip when a list or item is past its due window, green "Done" when current.
class DueBadge extends StatelessWidget {
  final bool due;
  const DueBadge({super.key, required this.due});
  @override
  Widget build(BuildContext context) {
    final color = due ? Colors.red : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.withValues(alpha: 0.15)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(due ? Icons.warning_amber_rounded : Icons.check_circle, size: 14, color: color),
        const SizedBox(width: 4),
        Text(due ? 'Due' : 'Done', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}
