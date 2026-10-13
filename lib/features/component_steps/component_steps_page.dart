import 'package:flutter/material.dart';
import '../editor/step_tile.dart';
import '../records/check_step.dart';
import '../maintenance_lists/maintenance_schedule.dart';

/// Full screen shown when tapping a component: title, back arrow, list of steps.
/// Owns a local copy of the component so edits update this page immediately,
/// then writes the new component back through [onComponentChanged].
class ComponentStepsPage extends StatefulWidget {
  final ComponentList component;
  final ValueChanged<ComponentList> onComponentChanged;
  final VoidCallback? onCommitted;
  const ComponentStepsPage({super.key, required this.component, required this.onComponentChanged, this.onCommitted});
  @override
  State<ComponentStepsPage> createState() => _ComponentStepsPageState();
}

class _ComponentStepsPageState extends State<ComponentStepsPage> {
  late ComponentList component = widget.component;

  void update(ComponentList next) {
    setState(() => component = next);
    widget.onComponentChanged(next);
  }

  void onStepChanged(CheckStep step) => update(component.copyWith(
        steps: component.steps.map((s) => s.id == step.id ? step : s).toList(),
      ));

  void onStepDeleted(String stepId) =>
      update(component.copyWith(steps: component.steps.where((s) => s.id != stepId).toList()));

  void onStepAdded() {
    final step = CheckStep(id: DateTime.now().microsecondsSinceEpoch.toString(), title: 'New item');
    update(component.copyWith(steps: [...component.steps, step]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(component.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
        children: [
          for (final step in component.steps)
            StepTile(step: step, onChanged: onStepChanged, onDelete: () => onStepDeleted(step.id), onCommitted: widget.onCommitted),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(onPressed: onStepAdded, icon: const Icon(Icons.add), label: const Text('Add item')),
            ),
          ),
        ],
      ),
    );
  }
}
