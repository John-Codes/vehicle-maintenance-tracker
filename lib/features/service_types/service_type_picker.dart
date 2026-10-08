import 'package:flutter/material.dart';
import 'service_type.dart';
import 'service_types_repository.dart';
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
        title: const Text('Service type'), children: types.isEmpty ? [const Padding(padding: EdgeInsets.all(24), child: Text('Add a service type in Settings.'))] : [
          for (final type in types) SimpleDialogOption(onPressed: () => Navigator.pop(ctx, type), child: Text(type.name))]));
      if (selected != null && mounted) widget.onSelected(selected);
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not load service types: $e'))); }
    finally { if (mounted) setState(() => loading = false); }
  }
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 32, bottom: 12),
    child: OutlinedButton.icon(onPressed: loading ? null : choose,
      icon: const Icon(Icons.list_alt), label: Text(loading ? 'Loading service types…' : 'Choose service type')));
}
