import 'package:flutter/material.dart';
import '../../core/large_display.dart';
import '../autosave/autosave_controller.dart';
import '../exports/export_service.dart';
import '../maintenance_lists/inspection_lists.dart';
import '../maintenance_lists/maintenance_schedule.dart';
import '../service_types/service_type.dart';
import '../service_types/template_changes.dart';
import '../records/records_repository.dart';
import '../records/service_record.dart';
import '../vehicle_service_history/vehicle_service_history.dart';
import 'record_form_fields.dart';
import 'record_values.dart';
import 'service_type_confirm.dart';

class RecordEditorPage extends StatefulWidget {
  final ServiceRecord record;
  const RecordEditorPage({super.key, required this.record});
  @override
  State<RecordEditorPage> createState() => _RecordEditorPageState();
}

class _RecordEditorPageState extends State<RecordEditorPage> {
  final repo = RecordsRepository();
  late ServiceRecord record;
  List<ServiceRecord> allRecords = const [];
  late final AutosaveController autosave;
  late final vehicle = TextEditingController(text: widget.record.vehicleNumber),
      vin = TextEditingController(text: widget.record.vin),
      plate = TextEditingController(text: widget.record.licensePlate),
      miles = TextEditingController(text: '${widget.record.miles ?? ''}'),
      hours = TextEditingController(text: '${widget.record.hours ?? ''}'),
      service = TextEditingController(text: widget.record.serviceType),
      workers = TextEditingController(text: widget.record.workerNames.join(', ')),
      notes = TextEditingController(text: widget.record.notes),
      next = TextEditingController(text: widget.record.nextSteps);
  @override
  void initState() {
    super.initState();
    record = widget.record;
    autosave = AutosaveController(value: values, repo: repo);
    autosave.watch([vehicle, vin, plate, miles, hours, service, workers, notes, next]);
    autosave.restore(record.id, _applyRecord).then((ok) { if (ok && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restored unsaved changes'))); });
    repo.list().then((r) { if (mounted) setState(() => allRecords = r); });
  }
  @override
  void dispose() {
    autosave.dispose();
    for (final c in [vehicle, vin, plate, miles, hours, service, workers, notes, next]) { c.dispose(); }
    super.dispose();
  }
  ServiceRecord values() => buildRecordValues(record,
      vehicle: vehicle, vin: vin, plate: plate, miles: miles, hours: hours, service: service, workers: workers, notes: notes, next: next);
  void _applyRecord(ServiceRecord r) {
    record = r;
    vehicle.text = r.vehicleNumber; vin.text = r.vin; plate.text = r.licensePlate;
    miles.text = '${r.miles ?? ''}'; hours.text = '${r.hours ?? ''}'; service.text = r.serviceType;
    workers.text = r.workerNames.join(', '); notes.text = r.notes; next.text = r.nextSteps;
    if (mounted) setState(() {});
  }
  void _scheduleChanged(MaintenanceSchedule schedule) { record = record.copyWith(schedule: schedule); autosave.touch(); setState(() {}); }
  Future<void> save() async {
    record = await repo.save(values());
    await autosave.clearDraft(record.id);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
  }
  Future<void> applyServiceType(ServiceType type) async {
    if (!await askReplaceSchedule(context, record, type)) return;
    setState(() {
      service.text = type.name;
      record = record.copyWith(serviceType: type.name, schedule: freshTemplate(type.schedule));
    });
    autosave.flush();
  }
  LastServiceInfo get lastService => VehicleServiceHistory.findLastServiceForUnit(allRecords.where((r) => r.id != record.id).toList(), vehicle.text);
  @override
  Widget build(BuildContext context) {
    final last = lastService;
    final big = biggerTextButtonsEnabled;
    return Scaffold(
      appBar: AppBar(title: const Text('Service record'), actions: [
        IconButton(onPressed: () => ExportService.pdf(values()), icon: const Icon(Icons.picture_as_pdf)),
        IconButton(onPressed: () => ExportService.xlsx(values()), icon: const Icon(Icons.table_chart)),
        IconButton(onPressed: save, icon: const Icon(Icons.save)),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        RecordFormFields(vehicle: vehicle, vin: vin, plate: plate, miles: miles, hours: hours, service: service, workers: workers, last: last, onType: applyServiceType, onVehicle: () => setState(() {})),
        const SizedBox(height: 12),
        const Text('Inspection', style: TextStyle(fontWeight: FontWeight.bold)),
        InspectionLists(schedule: record.schedule, onChanged: _scheduleChanged, onCommitted: autosave.flush),
        TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes')),
        TextField(controller: next, maxLines: 3, decoration: const InputDecoration(labelText: 'Next steps')),
        const SizedBox(height: 16),
        FilledButton(onPressed: save, style: FilledButton.styleFrom(minimumSize: big ? const Size.fromHeight(52) : null), child: const Text('Save record')),
      ]),
    );
  }
}
