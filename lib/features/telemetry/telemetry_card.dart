import 'package:flutter/material.dart';

import '../records/scan_sync.dart';
import '../records/service_record.dart';
import '../records/vehicle_icon.dart';
import '../telemetry/scanner_registry.dart';
import '../telemetry/pairing_wizard.dart';

/// Telemetry card inside the record editor: shows this record's own adapter,
/// offers sync / replace / pair. Updates flow back through onSave.
class TelemetryCard extends StatelessWidget {
  final ServiceRecord record;
  final void Function(ServiceRecord) onSave;

  const TelemetryCard({super.key, required this.record, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final paired = record.scanner.isNotEmpty;
    final label = paired
        ? ScannerRegistry.byId(record.scanner['id'] as String? ?? 'generic-elm327').label
        : 'No adapter paired for this ${labelForVehicleType(record.vehicleType)}';
    final lastSync = record.scanner['last_synced_at'] as String? ?? '';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(paired ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: paired ? const Color(0xff1fddb9) : Theme.of(context).hintColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Telemetry', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(paired && lastSync.isNotEmpty
                        ? '$label · synced ${lastSync.split('T').first}'
                        : label),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              if (paired) ...[
                FilledButton.icon(
                  onPressed: () => _sync(context),
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync now'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _replace(context),
                  icon: const Icon(Icons.bluetooth_searching),
                  label: const Text('Replace'),
                ),
              ] else
                FilledButton.icon(
                  onPressed: () => _replace(context),
                  icon: const Icon(Icons.bluetooth_searching),
                  label: const Text('Pair an adapter'),
                ),
            ]),
          ],
        ),
      ),
    );
  }

  Future<void> _sync(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final updated = await ScanSync().syncNow(record);
      onSave(updated);
      messenger.showSnackBar(SnackBar(
          content: Text('Synced: ${updated.miles?.toStringAsFixed(0) ?? 0} miles ✓')));
    } catch (err) {
      messenger.showSnackBar(SnackBar(content: Text('$err')));
    }
  }

  Future<void> _replace(BuildContext context) async {
    final updated = await Navigator.push<ServiceRecord>(context,
        MaterialPageRoute(builder: (_) => PairingWizard(record: record)));
    if (updated != null) onSave(updated);
  }
}
