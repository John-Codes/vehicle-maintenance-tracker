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
  const ComponentBlock({super.key, required this.component, required this.onStep, required this.onDelete, required this.onAdd, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final done = component.steps.isNotEmpty && component.steps.every((s) => s.done || s.notApplicable);
    return Card(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      child: ExpansionTile(
        leading: Checkbox(value: done, onChanged: (v) => onToggle(v ?? false)),
        title: Text(component.title),
        subtitle: Text('${component.steps.where((s) => s.done).length}/${component.steps.length}'),
        children: [
          for (final step in component.steps) StepTile(step: step, onChanged: onStep, onDelete: () => onDelete(step.id)),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add item')),
          ),
        ],
      ),
    );
  }
}
