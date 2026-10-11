import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'service_record.dart';

/// "How many miles are on it right now?" — updates the record's own
/// miles/hours. Telemetry is just a field on the record, nothing separate.
class MilesUpdatePage extends StatefulWidget {
  final ServiceRecord record;
  const MilesUpdatePage({super.key, required this.record});
  @override
  State<MilesUpdatePage> createState() => _MilesUpdatePageState();
}

class _MilesUpdatePageState extends State<MilesUpdatePage> {
  final odometer = TextEditingController();
  final hours = TextEditingController();
  var busy = false;

  @override
  void initState() {
    super.initState();
    odometer.text = widget.record.miles?.toStringAsFixed(0) ?? '';
    hours.text = widget.record.hours?.toStringAsFixed(0) ?? '';
  }

  @override
  void dispose() {
    odometer.dispose();
    hours.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final miles = double.tryParse(odometer.text.trim());
    if (miles == null || miles < 0) {
      _alert('Enter the miles shown on the odometer.');
      return;
    }
    setState(() => busy = true);
    final parsedHours = double.tryParse(hours.text.trim());
    final updated = widget.record.copyWith(
        miles: miles, hours: parsedHours ?? widget.record.hours);
    if (mounted) Navigator.pop(context, updated);
  }

  void _alert(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.record.vehicleNumber.isEmpty
        ? 'Update miles' : 'Update ${widget.record.vehicleNumber}')),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      const Text('How many miles are on it right now?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      const SizedBox(height: 24),
      TextField(controller: odometer, autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
          decoration: const InputDecoration(labelText: 'Miles on the odometer',
              prefixIcon: Icon(Icons.speed))),
      const SizedBox(height: 20),
      TextField(controller: hours, keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
          decoration: const InputDecoration(labelText: 'Engine hours (optional)',
              prefixIcon: Icon(Icons.schedule))),
      const SizedBox(height: 32),
      FilledButton(
        onPressed: busy ? null : save,
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        child: Text(busy ? 'Saving…' : 'Save'),
      ),
    ]),
  );
}
