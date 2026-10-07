import 'package:flutter/material.dart';
import '../maintenance_lists/maintenance_schedule.dart';
import 'service_type.dart';
import 'service_types_repository.dart';
import 'template_components.dart';
import 'template_schedule_editor.dart';
class ServiceTypeEditor extends StatefulWidget {
  final ServiceType? type;
  const ServiceTypeEditor({super.key, this.type});
  @override State<ServiceTypeEditor> createState() => _ServiceTypeEditorState();
}
class _ServiceTypeEditorState extends State<ServiceTypeEditor> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.type?.name ?? '');
  late MaintenanceSchedule schedule = widget.type?.schedule ?? MaintenanceSchedule.empty();
  bool saving = false, dirty = false;
  void changed(MaintenanceSchedule value) => setState(() { schedule = value; dirty = true; });
  @override void dispose() { name.dispose(); super.dispose(); }
  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      await ServiceTypesRepository().save(ServiceType(id: widget.type?.id ?? '', name: name.text.trim(), schedule: schedule));
      if (mounted) { setState(() => dirty = false); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service type saved')));
        WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) Navigator.pop(context); }); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save: $e'))); }
    finally { if (mounted) setState(() => saving = false); }
  }
  Future<void> confirmLeave() async {
    if (saving) return;
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Discard changes?'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep editing')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Discard'))]));
    if (yes == true && mounted) { setState(() => dirty = false); WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) Navigator.pop(context); }); }
  }
  @override Widget build(BuildContext context) => PopScope(canPop: !dirty && !saving,
    onPopInvokedWithResult: (didPop, _) { if (!didPop) confirmLeave(); },
    child: Scaffold(appBar: AppBar(title: Text(widget.type == null ? 'New service type' : 'Edit service type')),
      body: AbsorbPointer(absorbing: saving, child: Form(key: form, child: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(controller: name, maxLength: 120, decoration: const InputDecoration(labelText: 'Service type name'),
          onChanged: (_) => setState(() => dirty = true), validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null),
        const Text('Components', style: TextStyle(fontWeight: FontWeight.bold)),
        const Text('Components appear in all three frequencies. Add checklist items under each frequency below.'),
        TemplateComponents(schedule: schedule, onChanged: changed),
        TemplateScheduleEditor(schedule: schedule, onChanged: changed),
        const SizedBox(height: 20),
        FilledButton(onPressed: saving ? null : save, child: Text(saving ? 'Saving…' : 'Save service type')),
      ])))));
}
