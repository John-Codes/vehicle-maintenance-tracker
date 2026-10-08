import 'package:flutter/material.dart';
import '../editor/step_tile.dart';
import '../records/check_step.dart';
import 'maintenance_schedule.dart';

class ComponentBlock extends StatelessWidget {
  final ComponentList component;
  final ValueChanged<CheckStep> onStep;
  final ValueChanged<String> onDelete;
  final VoidCallback onAdd;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onCommitted;
  const ComponentBlock({super.key, required this.component, required this.onStep, required this.onDelete, required this.onAdd, required this.onToggle, this.onCommitted});

  @override
  Widget build(BuildContext context) {
    final incomplete = component.steps.any((s) => !s.done && !s.notApplicable);
    return Card(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      child: ExpansionTile(
        leading: Checkbox(value: !incomplete && component.steps.isNotEmpty, onChanged: (v) => onToggle(v ?? false)),
        title: Text(component.title),
        subtitle: Text('${component.steps.where((s) => s.done).length}/${component.steps.length}',
            style: TextStyle(color: incomplete ? Colors.red : Colors.green, fontWeight: FontWeight.w600)),
        children: [
          for (final step in component.steps)
            StepTile(step: step, onChanged: onStep, onDelete: () => onDelete(step.id), onCommitted: onCommitted),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add item')),
          ),
        ],
      ),
    );
  }
}
