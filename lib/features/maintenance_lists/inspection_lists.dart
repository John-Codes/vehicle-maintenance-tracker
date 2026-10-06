import 'package:flutter/material.dart';
import '../../core/large_display.dart';
import 'component_block.dart';
import 'maintenance_schedule.dart';
import 'schedule_edit.dart';

class InspectionLists extends StatefulWidget {
  final MaintenanceSchedule schedule;
  final ValueChanged<MaintenanceSchedule> onChanged;
  const InspectionLists({super.key, required this.schedule, required this.onChanged});
  @override
  State<InspectionLists> createState() => _InspectionListsState();
}

class _InspectionListsState extends State<InspectionLists> {
  String? openId;

  void write(String id, FrequencyList list) {
    final schedule = widget.schedule;
    widget.onChanged(switch (id) {
      'daily' => schedule.copyWith(daily: list),
      'weekly' => schedule.copyWith(weekly: list),
      _ => schedule.copyWith(monthly: list),
    });
  }

  void mark(String id, FrequencyList list) {
    write(id, markFrequencyDone(list));
    setState(() => openId = null);
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        _row('daily', 'Daily', widget.schedule.daily),
        _row('weekly', 'Weekly', widget.schedule.weekly),
        _row('monthly', 'Monthly', widget.schedule.monthly),
      ]);

  Widget _row(String id, String label, FrequencyList list) {
    final open = openId == id;
    final last = list.lastDoneAt.isEmpty ? 'Never' : list.lastDoneAt.split('T').first;
    return Column(children: [
      ListTile(
        leading: Checkbox(
          value: list.markedDone,
          onChanged: (v) => v == true ? mark(id, list) : write(id, clearFrequencyDone(list)),
        ),
        title: Text(label),
        subtitle: Text('Last done: $last'),
        trailing: Icon(open ? Icons.expand_less : Icons.expand_more),
        onTap: () => setState(() => openId = open ? null : id),
      ),
      if (open) ...[
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: FilledButton(
              onPressed: () => mark(id, list),
              style: FilledButton.styleFrom(minimumSize: biggerTextButtonsEnabled ? const Size(64, 52) : null),
              child: Text('Mark $label done'),
            ),
          ),
        ),
        if (list.components.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('Pick a service type to load components.')),
        for (final component in list.components)
          ComponentBlock(
            component: component,
            onStep: (step) => write(id, replaceStep(list, component.id, step)),
            onDelete: (stepId) => write(id, deleteStep(list, component.id, stepId)),
            onAdd: () => write(id, addStep(list, component.id)),
            onToggle: (done) => write(id, markComponentDone(list, component.id, done)),
          ),
      ],
    ]);
  }
}
