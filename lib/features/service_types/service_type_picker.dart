import 'package:flutter/material.dart';
import 'service_type.dart';
import 'vehicle_emoji.dart';
import 'service_types_repository.dart';

// UI label: "vehicle/equipment type" — the data field is still `service_type` (API: /service-types).
// Renamed at the UI level only, per BRANCH_UPDATE_RULES; no backend/data changes.
class ServiceTypePicker extends StatefulWidget {
  final ValueChanged<ServiceType> onSelected;
  const ServiceTypePicker({super.key, required this.onSelected});
  @override State<ServiceTypePicker> createState() => _ServiceTypePickerState();
}
class _ServiceTypePickerState extends State<ServiceTypePicker> {
  bool loading = false;
  Future<void> choose() async {
    setState(() => loading = true);
    try {
      final types = await ServiceTypesRepository().list();
      if (!mounted) return;
      final selected = await showDialog<ServiceType>(context: context, builder: (ctx) => SimpleDialog(
        title: const Text('Vehicle/equipment type'), children: types.isEmpty ? [const Padding(padding: EdgeInsets.all(24), child: Text('Add a vehicle/equipment type in Settings.'))] : [
          for (final type in types) SimpleDialogOption(onPressed: () => Navigator.pop(ctx, type),
              child: Text('${vehicleEmojiFor(vehicleTypeName: type.name)}  ${type.name}'))]));
      if (selected != null && mounted) widget.onSelected(selected);
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not load vehicle/equipment types: $e'))); }
    finally { if (mounted) setState(() => loading = false); }
  }
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 32, bottom: 12),
    child: OutlinedButton.icon(onPressed: loading ? null : choose,
      icon: const Icon(Icons.list_alt), label: Text(loading ? 'Loading types…' : 'Choose vehicle/equipment type')));
  }
