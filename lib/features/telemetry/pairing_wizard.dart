import 'package:flutter/material.dart';

import '../../core/cold_start_notice.dart';
import '../records/scan_sync.dart';
import '../records/service_record.dart';
import '../telemetry/transports/ble_transport.dart';

/// Pair-an-adapter wizard: plug it in -> found it -> test read -> paired.
/// Writes the binding onto THIS record so each vehicle keeps its own dongle.
class PairingWizard extends StatefulWidget {
  final ServiceRecord record;
  const PairingWizard({super.key, required this.record});
  @override
  State<PairingWizard> createState() => _PairingWizardState();
}

class _PairingWizardState extends State<PairingWizard> {
  var step = 0; // 0 instructions, 1 scanning, 2 testing, 3 done
  var message = '';
  var found = <DiscoveredAdapter>[];
  final sync = ScanSync();

  Future<void> scan() async {
    setState(() { step = 1; message = ''; });
    final transport = createBleTransport();
    if (!transport.isSupported) {
      setState(() => message = 'Bluetooth adapters are not supported on this '
          'browser. Use the Android app, or type the miles in.');
      return;
    }
    try {
      found = await transport.discover();
      setState(() => message =
          found.isEmpty ? 'No adapter found yet. Check it is plugged in and '
              'the key is ON, then try again.' : '');
    } catch (err) {
      setState(() => message = '$err');
    }
  }

  Future<void> pair(DiscoveredAdapter adapter) async {
    setState(() { step = 2; message = 'Reading your vehicle…'; });
    try {
      final reading = await sync.testRead(adapter.deviceId, widget.record);
      final record = await sync.pair(widget.record, adapter.deviceId);
      setState(() { step = 3; message = reading.odometerMi >= 0
          ? '${reading.odometerMi.toStringAsFixed(0)} miles read ✓'
          : 'Adapter paired ✓ (mileage will calibrate on the next sync)'; });
      if (mounted) {
        Navigator.pop(context, record.copyWith(scanner: record.scanner));
      }
    } catch (err) {
      setState(() { step = 1; message = '$err'; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Pair an adapter for ${widget.record.vehicleNumber.isEmpty ? 'this vehicle' : widget.record.vehicleNumber}')),
    body: step == 0 ? _instructions() :
          step == 3 ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.check_circle, color: Color(0xff1fddb9), size: 72),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
          ])) :
          _scanResults(),
    floatingActionButton: step == 0 ? FloatingActionButton.extended(
        onPressed: scan, icon: const Icon(Icons.bluetooth_searching),
        label: const Text('Find my adapter')) : null,
  );

  Widget _instructions() => ListView(padding: const EdgeInsets.all(24), children: [
    const Text('1. Plug the adapter into the port under the steering wheel.',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
    const SizedBox(height: 12),
    const Text('2. Turn the key to ON (engine off is fine).'),
    const SizedBox(height: 12),
    const Text('3. Tap "Find my adapter" below. That is it.'),
    const SizedBox(height: 24),
    Text('This adapter will stay linked to ${widget.record.vehicleNumber.isEmpty ? 'this vehicle' : widget.record.vehicleNumber} — '
        'every vehicle pairs its own adapter.',
        style: TextStyle(color: Theme.of(context).hintColor)),
  ]);

  Widget _scanResults() => step == 2 ? const Center(child: ColdStartNotice()) :
    Column(children: [
      if (message.isNotEmpty) Padding(padding: const EdgeInsets.all(20),
          child: Text(message, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.orange))),
      Expanded(child: ListView(children: [
        for (final adapter in found)
          ListTile(leading: const Icon(Icons.bluetooth),
              title: Text(adapter.displayName),
              subtitle: Text(adapter.rssi == 0 ? '' : '${adapter.rssi} dBm'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => pair(adapter)),
      ])),
    ]);
}
