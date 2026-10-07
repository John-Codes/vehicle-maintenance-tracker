import 'package:flutter/material.dart';
import '../records/check_step.dart';
import 'template_item_dialog.dart';

class TemplateItem extends StatelessWidget {
  final CheckStep step;
  final ValueChanged<CheckStep> onChanged;
  final VoidCallback onDelete;
  const TemplateItem({super.key, required this.step, required this.onChanged, required this.onDelete});
  Future<void> edit(BuildContext context) async {
    final result = await editTemplateItem(context, step);
    if (result != null && context.mounted) onChanged(result);
  }
  @override Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(step.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: step.description.isEmpty ? null : Text(step.description, maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: () => edit(context),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(tooltip: 'Edit todo', onPressed: () => edit(context), icon: const Icon(Icons.edit_outlined)),
        const SizedBox(width: 8),
        IconButton(tooltip: 'Delete todo', onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
      ]),
    ),
  );
}
