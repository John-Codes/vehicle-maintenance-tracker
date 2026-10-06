import 'package:flutter/material.dart';
import '../../core/large_display.dart';
import '../exports/export_service.dart';
import '../maintenance_lists/inspection_lists.dart';
import '../maintenance_lists/schedule_templates.dart';
import '../records/records_repository.dart';
import '../records/service_record.dart';
import '../vehicle_service_history/vehicle_service_history.dart';
import 'record_form_fields.dart';

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
    repo.list().then((r) { if (mounted) setState(() => allRecords = r); });
  }
  @override
  void dispose() {
    for (final c in [vehicle, vin, plate, miles, hours, service, workers, notes, next]) { c.dispose(); }
    super.dispose();
  }
  ServiceRecord values() => record.copyWith(
        vehicleNumber: vehicle.text,
        vin: vin.text,
        licensePlate: plate.text,
        serviceType: service.text,
        miles: num.tryParse(miles.text),
        hours: num.tryParse(hours.text),
        workerNames: workers.text.split(',').map((x) => x.trim()).where((x) => x.isNotEmpty).toList(),
        notes: notes.text,
        nextSteps: next.text,
      );
  Future<void> save() async {
    record = await repo.save(values());
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
  }
  Future<void> applyServiceType(String type) async {
    final hasSteps = record.schedule.leaves.isNotEmpty;
    var replace = !hasSteps;
    if (hasSteps) {
      final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
            title: Text('Use $type schedule?'),
            content: const Text('Replace the current checklist with that service type?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Use')),
            ],
          ));
      replace = confirmed ?? false;
    }
    if (!replace) return;
    setState(() {
      service.text = type;
      record = record.copyWith(serviceType: type, schedule: ScheduleTemplates.forType(type));
    });
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
        InspectionLists(schedule: record.schedule, onChanged: (schedule) => setState(() => record = record.copyWith(schedule: schedule))),
        TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes')),
        TextField(controller: next, maxLines: 3, decoration: const InputDecoration(labelText: 'Next steps')),
        const SizedBox(height: 16),
        FilledButton(onPressed: save, style: FilledButton.styleFrom(minimumSize: big ? const Size.fromHeight(52) : null), child: const Text('Save record')),
      ]),
    );
  }
}
