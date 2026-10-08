import 'package:flutter/material.dart';
import '../../core/large_display.dart';
import '../checklist_history/checklist_history.dart';
import 'component_block.dart';
import 'frequency_row.dart';
import 'maintenance_schedule.dart';
import 'schedule_edit.dart';

class InspectionLists extends StatefulWidget {
  final MaintenanceSchedule schedule;
  final ValueChanged<MaintenanceSchedule> onChanged;
  final VoidCallback onCommitted;
  const InspectionLists({super.key, required this.schedule, required this.onChanged, required this.onCommitted});
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

  Future<void> mark(String id, FrequencyList list) => ChecklistHistory.markFrequency(
      list: list, write: (l) => write(id, l), onCommitted: widget.onCommitted);

  void clear(String id, FrequencyList list) => ChecklistHistory.clearFrequency(
      list: list, write: (l) => write(id, l), onCommitted: widget.onCommitted);

  Future<void> toggleComponent(String id, FrequencyList list, String componentId, bool done) =>
      ChecklistHistory.toggleComponent(
          list: list, componentId: componentId, done: done, write: (l) => write(id, l), onCommitted: widget.onCommitted);

  @override
  Widget build(BuildContext context) => Column(children: [
        _row('daily', 'Daily', widget.schedule.daily),
        _row('weekly', 'Weekly', widget.schedule.weekly),
        _row('monthly', 'Monthly', widget.schedule.monthly),
      ]);

  Widget _row(String id, String label, FrequencyList list) {
    final open = openId == id;
    return Column(children: [
      FrequencyRow(
        id: id,
        label: label,
        list: list,
        open: open,
        onTap: () => setState(() => openId = open ? null : id),
        onCheck: (v) {
          if (v) {
            mark(id, list);
          } else {
            clear(id, list);
          }
        },
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
            onToggle: (done) => toggleComponent(id, list, component.id, done),
            onCommitted: widget.onCommitted,
          ),
      ],
    ]);
  }
}
