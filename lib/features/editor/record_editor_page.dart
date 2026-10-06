import 'package:flutter/material.dart';
import '../../core/large_display.dart';
import '../exports/export_service.dart';
import '../records/check_step.dart';
import '../records/records_repository.dart';
import '../records/service_record.dart';
import '../service_type_templates/service_type_templates.dart';
import '../vehicle_service_history/vehicle_service_history.dart';
import 'step_tile.dart';

class RecordEditorPage extends StatefulWidget { final ServiceRecord record; const RecordEditorPage({super.key, required this.record}); @override State<RecordEditorPage> createState() => _RecordEditorPageState(); }
class _RecordEditorPageState extends State<RecordEditorPage> {
  final repo = RecordsRepository(); late ServiceRecord record; List<ServiceRecord> allRecords = const [];
  late final vehicle = TextEditingController(text: widget.record.vehicleNumber), vin = TextEditingController(text: widget.record.vin), plate = TextEditingController(text: widget.record.licensePlate),
    miles = TextEditingController(text: '${widget.record.miles ?? ''}'), hours = TextEditingController(text: '${widget.record.hours ?? ''}'),
    service = TextEditingController(text: widget.record.serviceType), workers = TextEditingController(text: widget.record.workerNames.join(', ')),
    notes = TextEditingController(text: widget.record.notes), next = TextEditingController(text: widget.record.nextSteps);
  @override void initState() { super.initState(); record = widget.record; repo.list().then((r) { if (mounted) setState(() => allRecords = r); }); }
  @override void dispose() { for (final c in [vehicle, vin, plate, miles, hours, service, workers, notes, next]) { c.dispose(); } super.dispose(); }
  ServiceRecord values() => record.copyWith(vehicleNumber: vehicle.text, vin: vin.text, licensePlate: plate.text, serviceType: service.text, miles: num.tryParse(miles.text), hours: num.tryParse(hours.text), workerNames: workers.text.split(',').map((x) => x.trim()).where((x) => x.isNotEmpty).toList(), notes: notes.text, nextSteps: next.text);
  Future<void> save() async { record = await repo.save(values()); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved'))); }
  void update(CheckStep step) => setState(() => record = record.copyWith(steps: record.steps.map((x) => x.id == step.id ? step : x).toList()));
  void applyServiceType(String type) async {
    final templateSteps = ServiceTypeTemplates.getSteps(type);
    bool replace = record.steps.isEmpty;
    if (!replace) {
      final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
        title: Text('Use $type checklist?'),
        content: Text(templateSteps.isEmpty ? 'Clear the current checklist so you can build your own steps?' : 'Replace the current checklist with the $type steps (${templateSteps.length} items)?'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Use'))]));
      replace = confirmed ?? false;
    }
    if (!replace) return;
    setState(() { service.text = type; record = record.copyWith(serviceType: type, steps: templateSteps.map((t) => CheckStep(id: t.id, title: t.title, description: t.desc)).toList()); });
  }
  LastServiceInfo get lastService => VehicleServiceHistory.findLastServiceForUnit(allRecords.where((r) => r.id != record.id).toList(), vehicle.text);
  @override Widget build(BuildContext context) {
    final last = lastService;
    return Scaffold(
      appBar: AppBar(title: const Text('Service record'), actions: [IconButton(onPressed: () => ExportService.pdf(values()), icon: const Icon(Icons.picture_as_pdf)), IconButton(onPressed: () => ExportService.xlsx(values()), icon: const Icon(Icons.table_chart)), IconButton(onPressed: save, icon: const Icon(Icons.save))]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: vehicle, decoration: const InputDecoration(labelText: 'Vehicle number'), onChanged: (_) => setState(() {})),
        if (last.hasLastService) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Last serviced: ${last.lastServiceDate.split('T').first}', style: const TextStyle(color: Colors.green))) else if (vehicle.text.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: const Text('No record of service for this unit', style: TextStyle(color: Colors.grey))),
        if (last.hasLastService && last.lastServiceSteps.isNotEmpty) TextButton(onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(title: Text('Steps from last service'), content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final s in last.lastServiceSteps) Text('• ${s.title}${s.done ? ' (done)' : s.notApplicable ? ' (N/A)' : ''}')])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))])), child: const Text('View steps from last service')),
        Row(children: [Expanded(child: TextField(controller: vin, decoration: const InputDecoration(labelText: 'VIN'), textCapitalization: TextCapitalization.characters)), const SizedBox(width: 12), Expanded(child: TextField(controller: plate, decoration: const InputDecoration(labelText: 'License plate'), textCapitalization: TextCapitalization.characters))]),
        Row(children: [Expanded(child: TextField(controller: miles, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Miles'))), const SizedBox(width: 12), Expanded(child: TextField(controller: hours, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hours')))]),
        DropdownButtonFormField(items: [for (final t in ServiceTypeTemplates.getServiceTypes()) DropdownMenuItem(value: t, child: Text(t))], onChanged: (t) => applyServiceType(t!), decoration: const InputDecoration(labelText: 'Service type')),
        TextField(controller: service, decoration: const InputDecoration(labelText: 'Service type (custom text)')),
        TextField(controller: workers, decoration: const InputDecoration(labelText: 'Worker names (comma separated)')),
        const SizedBox(height: 12), const Text('Inspection', style: TextStyle(fontWeight: FontWeight.bold)),
        ...record.steps.map((s) => StepTile(step: s, onChanged: update, onDelete: () => setState(() => record = record.copyWith(steps: record.steps.where((x) => x.id != s.id).toList())))),
        OutlinedButton.icon(onPressed: () => setState(() => record = record.copyWith(steps: [...record.steps, CheckStep(id: DateTime.now().microsecondsSinceEpoch.toString(), title: 'New item')])), style: OutlinedButton.styleFrom(minimumSize: biggerTextButtonsEnabled ? const Size.fromHeight(52) : null), icon: const Icon(Icons.add), label: const Text('Add item')),
        TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes')),
        TextField(controller: next, maxLines: 3, decoration: const InputDecoration(labelText: 'Next steps')),
        const SizedBox(height: 16), FilledButton(onPressed: save, style: FilledButton.styleFrom(minimumSize: biggerTextButtonsEnabled ? const Size.fromHeight(52) : null), child: const Text('Save record')),
      ]),
    );
  }
}
