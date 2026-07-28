import 'package:flutter/material.dart';
import '../exports/export_service.dart';
import '../records/check_step.dart';
import '../records/records_repository.dart';
import '../records/service_record.dart';
import 'step_tile.dart';

class RecordEditorPage extends StatefulWidget { final ServiceRecord record; const RecordEditorPage({super.key, required this.record}); @override State<RecordEditorPage> createState() => _RecordEditorPageState(); }
class _RecordEditorPageState extends State<RecordEditorPage> {
  final repo = RecordsRepository(); late ServiceRecord record; late final vehicle = TextEditingController(text: widget.record.vehicleNumber), miles = TextEditingController(text: '${widget.record.miles ?? ''}'), hours = TextEditingController(text: '${widget.record.hours ?? ''}'), service = TextEditingController(text: widget.record.serviceType), workers = TextEditingController(text: widget.record.workerNames.join(', ')), notes = TextEditingController(text: widget.record.notes), next = TextEditingController(text: widget.record.nextSteps);
  @override void initState() { super.initState(); record = widget.record; }
  @override void dispose() { for (final c in [vehicle,miles,hours,service,workers,notes,next]) { c.dispose(); } super.dispose(); }
  ServiceRecord values() => record.copyWith(vehicleNumber: vehicle.text, serviceType: service.text, miles: num.tryParse(miles.text), hours: num.tryParse(hours.text), workerNames: workers.text.split(',').map((x) => x.trim()).where((x) => x.isNotEmpty).toList(), notes: notes.text, nextSteps: next.text);
  Future<void> save() async { record = await repo.save(values()); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved'))); }
  void update(CheckStep step) => setState(() => record = record.copyWith(steps: record.steps.map((x) => x.id == step.id ? step : x).toList()));
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Service record'), actions: [IconButton(onPressed: () => ExportService.pdf(values()), icon: const Icon(Icons.picture_as_pdf)), IconButton(onPressed: () => ExportService.xlsx(values()), icon: const Icon(Icons.table_chart)), IconButton(onPressed: save, icon: const Icon(Icons.save))]),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      TextField(controller: vehicle, decoration: const InputDecoration(labelText: 'Vehicle number')),
      Row(children: [Expanded(child: TextField(controller: miles, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Miles'))), const SizedBox(width: 12), Expanded(child: TextField(controller: hours, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hours')))]),
      TextField(controller: service, decoration: const InputDecoration(labelText: 'Service type')), TextField(controller: workers, decoration: const InputDecoration(labelText: 'Worker names (comma separated)')),
      const SizedBox(height: 12), const Text('Inspection', style: TextStyle(fontWeight: FontWeight.bold)), ...record.steps.map((s) => StepTile(step: s, onChanged: update, onDelete: () => setState(() => record = record.copyWith(steps: record.steps.where((x) => x.id != s.id).toList())))),
      OutlinedButton.icon(onPressed: () => setState(() => record = record.copyWith(steps: [...record.steps, CheckStep(id: DateTime.now().microsecondsSinceEpoch.toString(), title: 'New item')])), icon: const Icon(Icons.add), label: const Text('Add item')),
      TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes')), TextField(controller: next, maxLines: 3, decoration: const InputDecoration(labelText: 'Next steps')), const SizedBox(height: 16), FilledButton(onPressed: save, child: const Text('Save record')),
    ]),
  );
}
