import 'package:flutter/material.dart';
import '../records/check_step.dart';

Future<CheckStep?> editTemplateItem(BuildContext context, CheckStep step) =>
    showDialog<CheckStep>(context: context, builder: (_) => _ItemDialog(step: step));

class _ItemDialog extends StatefulWidget {
  final CheckStep step;
  const _ItemDialog({required this.step});
  @override State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  final form = GlobalKey<FormState>();
  late final title = TextEditingController(text: widget.step.title);
  late final description = TextEditingController(text: widget.step.description);
  late final value = TextEditingController(text: widget.step.value);
  late final notes = TextEditingController(text: widget.step.notes);
  @override void dispose() {
    for (final controller in [title, description, value, notes]) { controller.dispose(); }
    super.dispose();
  }
  void save() {
    if (!form.currentState!.validate()) return;
    Navigator.pop(context, widget.step.copyWith(title: title.text.trim(),
      description: description.text, value: value.text, notes: notes.text));
  }
  @override Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.step.title.isEmpty ? 'Add todo' : 'Edit todo'),
    content: SizedBox(width: 480, child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .6),
      child: SingleChildScrollView(child: Form(key: form, child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(controller: title, autofocus: true, maxLength: 120,
            decoration: const InputDecoration(labelText: 'Todo title'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter a title' : null),
          const SizedBox(height: 16),
          TextFormField(controller: description, minLines: 2, maxLines: 4,
            decoration: const InputDecoration(labelText: 'Instructions / description')),
          const SizedBox(height: 16),
          TextFormField(controller: value,
            decoration: const InputDecoration(labelText: 'Location/Measurement/Readings')),
          const SizedBox(height: 16),
          TextFormField(controller: notes, minLines: 2, maxLines: 4,
            decoration: const InputDecoration(labelText: 'Notes')),
        ],
      ))))),
    actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: save, child: const Text('Save todo')),
    ],
  );
}
