import 'package:flutter/material.dart';
import '../service_types/service_type.dart';
import '../service_types/service_type_picker.dart';
import '../vehicle_service_history/vehicle_service_history.dart';

// UI label: "vehicle/equipment type" — the data field is still `service_type` (API: /service-types).
// Renamed at the UI level only, per BRANCH_UPDATE_RULES; no backend/data changes.

class RecordFormFields extends StatelessWidget {
  final TextEditingController vehicle, vin, plate, miles, hours, service, workers, brand, model, year;
  final LastServiceInfo last;
  final ValueChanged<ServiceType> onType;
  final VoidCallback? onGenerateAi;
  final VoidCallback onVehicle;
  const RecordFormFields({super.key, required this.vehicle, required this.vin, required this.plate, required this.miles, required this.hours, required this.service, required this.workers, required this.brand, required this.model, required this.year, required this.last, required this.onType, required this.onVehicle, this.onGenerateAi});

  @override
  Widget build(BuildContext context) => Column(children: [
        TextField(controller: vehicle, decoration: const InputDecoration(labelText: 'Vehicle number'), onChanged: (_) => onVehicle()),
        if (last.hasLastService) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Last serviced: ${last.lastServiceDate.split('T').first}', style: const TextStyle(color: Colors.green))) else if (vehicle.text.isNotEmpty) const Padding(padding: EdgeInsets.only(top: 8), child: Text('No record of service for this unit', style: TextStyle(color: Colors.grey))),
        if (last.hasLastService && last.lastServiceSteps.isNotEmpty)
          TextButton(onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Steps from last service'), content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final s in last.lastServiceSteps) Text('• ${s.title}${s.done ? ' (done)' : ''}')])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))])), child: const Text('View steps from last service')),
        Row(children: [Expanded(child: TextField(controller: brand, decoration: const InputDecoration(labelText: 'Brand (e.g. Toyota)'))), const SizedBox(width: 12), Expanded(child: TextField(controller: model, decoration: const InputDecoration(labelText: 'Model (e.g. Prius)'))), const SizedBox(width: 12), SizedBox(width: 90, child: TextField(controller: year, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Year')))]),
        Row(children: [Expanded(child: TextField(controller: vin, decoration: const InputDecoration(labelText: 'VIN'), textCapitalization: TextCapitalization.characters)), const SizedBox(width: 12), Expanded(child: TextField(controller: plate, decoration: const InputDecoration(labelText: 'License plate'), textCapitalization: TextCapitalization.characters))]),
        Row(children: [Expanded(child: TextField(controller: miles, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Miles'))), const SizedBox(width: 12), Expanded(child: TextField(controller: hours, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hours')))]),
        ServiceTypePicker(onSelected: onType),
        if (onGenerateAi != null)
          Align(alignment: Alignment.centerRight, child: IconButton(
            icon: const Icon(Icons.auto_awesome, color: Color(0xff1fddb9)),
            tooltip: 'Get basic maintenance information with AI',
            onPressed: onGenerateAi,
          )),
        TextField(controller: service, decoration: const InputDecoration(labelText: 'Vehicle/equipment type (custom text)')),
        TextField(controller: workers, decoration: const InputDecoration(labelText: 'Worker names (comma separated)')),
      ]);
}
