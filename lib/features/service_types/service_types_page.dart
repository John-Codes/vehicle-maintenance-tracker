import 'package:flutter/material.dart';
import 'service_type.dart';
import 'service_types_repository.dart';
import 'service_type_editor.dart';
class ServiceTypesPage extends StatefulWidget {
  const ServiceTypesPage({super.key});
  @override State<ServiceTypesPage> createState() => _ServiceTypesPageState();
}
class _ServiceTypesPageState extends State<ServiceTypesPage> {
  final repo = ServiceTypesRepository();
  late Future<List<ServiceType>> types = repo.list();
  bool deleting = false;
  void refresh() { if (mounted) setState(() => types = repo.list()); }
  Future<void> edit([ServiceType? type]) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceTypeEditor(type: type)));
    refresh();
  }
  Future<void> remove(ServiceType type) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text('Delete ${type.name}?'), content: const Text('Existing service records will keep their saved checklist.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete'))]));
    if (yes != true || !mounted) return;
    setState(() => deleting = true);
    try { await repo.delete(type.id); refresh(); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not delete: $e'))); }
    finally { if (mounted) setState(() => deleting = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Service types')),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => edit(), icon: const Icon(Icons.add), label: const Text('Add service type')),
    body: FutureBuilder<List<ServiceType>>(future: types, builder: (_, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Could not load service types: ${snapshot.error}'), TextButton(onPressed: refresh, child: const Text('Retry'))]));
      if (snapshot.data!.isEmpty) return const Center(child: Text('Add your first service type.'));
      return ListView(padding: const EdgeInsets.only(bottom: 90), children: [for (final type in snapshot.data!) ListTile(
        title: Text(type.name), subtitle: Text('${type.schedule.leaves.length} checklist items'),
        onTap: () => edit(type), trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(tooltip: 'Edit', onPressed: () => edit(type), icon: const Icon(Icons.edit_outlined)),
          IconButton(tooltip: 'Delete', onPressed: deleting ? null : () => remove(type), icon: const Icon(Icons.delete_outline))]))]);
    }));
}
