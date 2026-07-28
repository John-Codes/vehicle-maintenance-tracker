import 'package:flutter/material.dart';
import '../records/check_step.dart';

class StepTile extends StatefulWidget {
  final CheckStep step;
  final ValueChanged<CheckStep> onChanged;
  final VoidCallback onDelete;
  const StepTile({super.key, required this.step, required this.onChanged, required this.onDelete});
  @override State<StepTile> createState() => _StepTileState();
}
class _StepTileState extends State<StepTile> {
  late final title = TextEditingController(text: widget.step.title), value = TextEditingController(text: widget.step.value), notes = TextEditingController(text: widget.step.notes);
  @override void dispose() { title.dispose(); value.dispose(); notes.dispose(); super.dispose(); }
  void change({bool? done}) => widget.onChanged(widget.step.copyWith(title: title.text, done: done, value: value.text, notes: notes.text));
  @override Widget build(BuildContext context) => Card(child: ExpansionTile(
    leading: Checkbox(value: widget.step.done, onChanged: (x) => change(done: x)),
    title: Text(widget.step.title),
    trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: widget.onDelete),
    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    children: [TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')), TextField(controller: value, decoration: const InputDecoration(labelText: 'Value')), TextField(controller: notes, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes')), Align(alignment: Alignment.centerRight, child: TextButton(onPressed: change, child: const Text('Apply')))],
  ));
}
