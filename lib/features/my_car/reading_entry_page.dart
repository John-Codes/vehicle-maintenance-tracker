import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'telemetry_repository.dart';

/// Plain-English form: "How many miles are on it right now?"
class ReadingEntryPage extends StatefulWidget {
  const ReadingEntryPage({super.key});
  @override
  State<ReadingEntryPage> createState() => _ReadingEntryPageState();
}

class _ReadingEntryPageState extends State<ReadingEntryPage> {
  final repo = TelemetryRepository();
  final vehicle = TextEditingController();
  final odometer = TextEditingController();
  final hours = TextEditingController();
  final notes = TextEditingController();
  var busy = false;

  @override
  void dispose() {
    vehicle.dispose(); odometer.dispose(); hours.dispose(); notes.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final miles = double.tryParse(odometer.text.trim());
    if (vehicle.text.trim().isEmpty) { _alert('Which vehicle is this? Enter a name like "My Prius".'); return; }
    if (miles == null || miles < 0) { _alert('Enter the miles shown on the odometer.'); return; }
    setState(() => busy = true);
    try {
      final parsedHours = double.tryParse(hours.text.trim());
      await repo.add(
          vehicleNumber: vehicle.text.trim(),
          odometerMi: miles,
          engineHours: parsedHours,
          notes: notes.text.trim());
      if (mounted) Navigator.pop(context);
    } catch (err) {
      _alert('$err');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _alert(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Log a reading')),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      const Text('How many miles are on it right now?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      const SizedBox(height: 24),
      TextField(controller: vehicle,
          decoration: const InputDecoration(labelText: 'Vehicle name',
              hintText: 'e.g. My Prius', prefixIcon: Icon(Icons.directions_car_outlined))),
      const SizedBox(height: 20),
      TextField(controller: odometer, keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
          decoration: const InputDecoration(labelText: 'Miles on the odometer',
              prefixIcon: Icon(Icons.speed))),
      const SizedBox(height: 20),
      TextField(controller: hours, keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
          decoration: const InputDecoration(labelText: 'Engine hours (optional)',
              prefixIcon: Icon(Icons.schedule))),
      const SizedBox(height: 20),
      TextField(controller: notes,
          decoration: const InputDecoration(labelText: 'Note (optional)',
              prefixIcon: Icon(Icons.notes))),
      const SizedBox(height: 32),
      FilledButton(
        onPressed: busy ? null : save,
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        child: Text(busy ? 'Saving…' : 'Save reading'),
      ),
    ]),
  );
}
