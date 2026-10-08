import 'package:flutter/material.dart';
import '../checklist_history/checklist_history.dart';
import 'maintenance_schedule.dart';

class FrequencyRow extends StatelessWidget {
  final String id, label;
  final FrequencyList list;
  final bool open;
  final VoidCallback onTap;
  final ValueChanged<bool> onCheck;
  const FrequencyRow({super.key, required this.id, required this.label, required this.list, required this.open, required this.onTap, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    final due = isFrequencyDue(frequencyId: id, lastDoneAt: list.lastDoneAt);
    final last = list.lastDoneAt.isEmpty ? 'Never' : list.lastDoneAt.split('T').first;
    return ListTile(
      leading: Checkbox(value: !due, onChanged: (v) => onCheck(v ?? false)),
      title: Text(label),
      subtitle: Row(children: [
        Flexible(child: Text('Last done: $last')),
        const SizedBox(width: 8),
        DueBadge(due: due),
      ]),
      trailing: Icon(open ? Icons.expand_less : Icons.expand_more),
      onTap: onTap,
    );
  }
}
