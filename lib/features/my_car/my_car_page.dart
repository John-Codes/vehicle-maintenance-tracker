import 'package:flutter/material.dart';

import '../../core/cold_start_notice.dart';
import 'reading_entry_page.dart';
import 'telemetry_repository.dart';

/// "My car": current mileage card, log-a-reading button, readings history.
class MyCarPage extends StatefulWidget {
  const MyCarPage({super.key});
  @override
  State<MyCarPage> createState() => _MyCarPageState();
}

class _MyCarPageState extends State<MyCarPage> {
  final repo = TelemetryRepository();
  late Future<List<TelemetryReading>> readings;

  @override
  void initState() { super.initState(); readings = repo.list(); }
  void refresh() => setState(() => readings = repo.list());

  Future<void> logReading() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingEntryPage()));
    refresh();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My car')),
    body: FutureBuilder<List<TelemetryReading>>(future: readings, builder: (_, snap) {
      if (snap.connectionState != ConnectionState.done) return const ColdStartNotice();
      if (snap.hasError) return Center(child: Text('${snap.error}'));
      final items = snap.data!;
      if (items.isEmpty) {
        return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.directions_car_outlined, size: 72),
          const SizedBox(height: 12),
          const Text('No readings yet.\nLog your mileage to start tracking.',
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton.icon(onPressed: logReading,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              icon: const Icon(Icons.add), label: const Text('Log a reading')),
        ]),
        );
      }
      final latest = items.first;
      return Column(children: [
        Card(margin: const EdgeInsets.all(16), child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Text(latest.vehicleNumber, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('${latest.odometerMi.toStringAsFixed(0)} miles',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800)),
            if (latest.engineHours != null) ...[
              const SizedBox(height: 4),
              Text('${latest.engineHours!.toStringAsFixed(0)} engine hours',
                  style: Theme.of(context).textTheme.bodyLarge),
            ],
            const SizedBox(height: 8),
            Text('As of ${latest.capturedDay} · ${latest.source == 'manual' ? 'you entered' : latest.source}',
                style: Theme.of(context).textTheme.bodySmall),
          ]),
        )),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilledButton.icon(onPressed: logReading,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              icon: const Icon(Icons.add), label: const Text('Log a reading'))),
        const SizedBox(height: 8),
        Expanded(child: ListView.builder(itemCount: items.length, itemBuilder: (_, i) {
          final reading = items[i];
          return ListTile(
            leading: const Icon(Icons.speed_outlined),
            title: Text('${reading.odometerMi.toStringAsFixed(0)} mi'
                '${reading.engineHours != null ? ' · ${reading.engineHours!.toStringAsFixed(0)} hrs' : ''}'),
            subtitle: Text('${reading.vehicleNumber} · ${reading.capturedDay}'
                '${reading.notes.isEmpty ? '' : ' · ${reading.notes}'}'),
          );
        })),
      ]);
    }),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: logReading, icon: const Icon(Icons.add), label: const Text('Add')),
  );
}
