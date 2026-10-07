import 'package:flutter/material.dart';
import '../maintenance_lists/maintenance_schedule.dart';
import 'template_changes.dart';
class TemplateComponents extends StatelessWidget {
  final MaintenanceSchedule schedule;
  final ValueChanged<MaintenanceSchedule> onChanged;
  const TemplateComponents({super.key, required this.schedule, required this.onChanged});
  Future<void> edit(BuildContext context, [ComponentList? component]) async {
    final controller = TextEditingController(text: component?.title ?? '');
    final name = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: Text(component == null ? 'Add component' : 'Rename component'),
      content: TextField(controller: controller, autofocus: true, maxLength: 120, decoration: const InputDecoration(labelText: 'Component name')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () { if (controller.text.trim().isNotEmpty) Navigator.pop(ctx, controller.text.trim()); }, child: const Text('Save'))]));
    if (name != null) onChanged(changeComponents(schedule, component?.id ?? DateTime.now().microsecondsSinceEpoch.toString(), name));
  }
  Future<void> remove(BuildContext context, ComponentList c) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text('Delete ${c.title}?'), content: const Text('This removes its items from Daily, Weekly, and Monthly in this template.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete'))]));
    if (yes == true) onChanged(changeComponents(schedule, c.id, null));
  }
  @override Widget build(BuildContext context) => Column(children: [
    for (final c in schedule.daily.components) ListTile(title: Text(c.title), trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(tooltip: 'Rename component', onPressed: () => edit(context, c), icon: const Icon(Icons.edit_outlined)),
      IconButton(tooltip: 'Delete component', onPressed: () => remove(context, c), icon: const Icon(Icons.delete_outline))])),
    TextButton.icon(onPressed: () => edit(context), icon: const Icon(Icons.add), label: const Text('Add component')),
  ]);
}
