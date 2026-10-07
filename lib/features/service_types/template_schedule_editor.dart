import 'package:flutter/material.dart';
import '../maintenance_lists/maintenance_schedule.dart';
import '../maintenance_lists/schedule_edit.dart';
import '../records/check_step.dart';
import 'template_item.dart';
import 'template_item_dialog.dart';

class TemplateScheduleEditor extends StatelessWidget {
  final MaintenanceSchedule schedule;
  final ValueChanged<MaintenanceSchedule> onChanged;
  const TemplateScheduleEditor({super.key, required this.schedule, required this.onChanged});
  Future<void> add(BuildContext context, FrequencyList list, ComponentList component, ValueChanged<FrequencyList> write) async {
    final step = await editTemplateItem(context, CheckStep(id: DateTime.now().microsecondsSinceEpoch.toString(), title: ''));
    if (step == null || !context.mounted) return;
    write(list.copyWith(components: [for (final c in list.components)
      if (c.id == component.id) c.copyWith(steps: [...c.steps, step]) else c]));
  }
  @override Widget build(BuildContext context) => Column(children: [
    frequency(context, 'Daily', schedule.daily, (v) => onChanged(schedule.copyWith(daily: v))),
    frequency(context, 'Weekly', schedule.weekly, (v) => onChanged(schedule.copyWith(weekly: v))),
    frequency(context, 'Monthly', schedule.monthly, (v) => onChanged(schedule.copyWith(monthly: v))),
  ]);
  Widget frequency(BuildContext context, String title, FrequencyList list, ValueChanged<FrequencyList> write) => ExpansionTile(
    key: PageStorageKey(title), title: Text(title), children: [for (final c in list.components) ExpansionTile(
      key: PageStorageKey('$title-${c.id}'), title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Align(alignment: Alignment.centerLeft, child: OutlinedButton.icon(
            onPressed: () => add(context, list, c, write), icon: const Icon(Icons.add), label: const Text('Add todo')))),
        for (final s in c.steps) TemplateItem(key: ValueKey(s.id), step: s,
          onChanged: (v) => write(replaceStep(list, c.id, v)), onDelete: () => write(deleteStep(list, c.id, s.id))),
        const SizedBox(height: 12),
      ])]);
}
