import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/large_display.dart';
import '../../core/cold_start_notice.dart';
import '../editor/record_editor_page.dart';
import 'record_search_bar.dart';
import 'records_repository.dart';
import 'service_record.dart';

class RecordsPage extends StatefulWidget { const RecordsPage({super.key}); @override State<RecordsPage> createState() => _RecordsPageState(); }
class _RecordsPageState extends State<RecordsPage> {
  final repo = RecordsRepository(); late Future<List<ServiceRecord>> records;
  final searchTextController = TextEditingController(); Timer? searchDebounce; String searchText = '';
  @override void initState() { super.initState(); records = repo.list(); }
  @override void dispose() { searchDebounce?.cancel(); searchTextController.dispose(); super.dispose(); }
  void refresh() => setState(() => records = repo.list(search: searchText));
  void onSearchChanged(String text) {
    searchDebounce?.cancel();
    searchDebounce = Timer(const Duration(milliseconds: 300), () => setState(() { searchText = text; records = repo.list(search: searchText); }));
  }
  Future<void> create() async { final record = await repo.create(); if (mounted) { await Navigator.push(context, MaterialPageRoute(builder: (_) => RecordEditorPage(record: record))); refresh(); } }
  Future<void> confirmDelete(ServiceRecord r) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete record?'),
      content: Text('Delete ${r.vehicleNumber.isEmpty ? 'this record' : r.vehicleNumber}? This cannot be undone.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red)))],
    ));
    if (yes == true) { await repo.delete(r.id); refresh(); }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Service records')),
    body: Column(children: [
      RecordSearchBar(controller: searchTextController, onChanged: onSearchChanged),
      Expanded(child: FutureBuilder<List<ServiceRecord>>(future: records, builder: (_, snap) {
      if (snap.connectionState != ConnectionState.done) return const ColdStartNotice();
      if (snap.hasError) return Center(child: Text('Could not load records\n${snap.error}\nIf the free-tier database was asleep, try again.', textAlign: TextAlign.center));
      if (snap.data!.isEmpty) return Center(child: Text(searchText.isEmpty ? 'Start your first service record.' : 'No records match "$searchText".'));
      return ListView.builder(itemCount: snap.data!.length, itemBuilder: (_, i) { final r = snap.data![i]; final leaves = r.schedule.leaves; final done = leaves.where((x) => x.done).length;       return Dismissible(
        key: ValueKey(r.id),
        direction: DismissDirection.endToStart,
        background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: Colors.red, child: const Icon(Icons.delete, color: Colors.white)),
        confirmDismiss: (_) async { await confirmDelete(r); return false; },
        child: ListTile(minVerticalPadding: biggerTextButtonsEnabled ? 12 : null, contentPadding: biggerTextButtonsEnabled ? const EdgeInsets.symmetric(horizontal: 20, vertical: 8) : null,
          title: Text(r.vehicleNumber.isEmpty ? 'New service record' : r.vehicleNumber), subtitle: Text('${r.dateStarted.split('T').first} · $done/${leaves.length} complete'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => confirmDelete(r)),
            const Icon(Icons.chevron_right),
          ]),
          onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => RecordEditorPage(record: r))); refresh(); }),
      ); });
      })),
    ]),
    floatingActionButton: FloatingActionButton.extended(onPressed: create, icon: const Icon(Icons.add), label: const Text('New record')),
  );
}
