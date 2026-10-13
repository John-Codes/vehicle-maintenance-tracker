import 'package:flutter/material.dart';

import '../records/miles_update_page.dart';
import '../records/scan_sync.dart';
import '../records/service_record.dart';
import '../records/vehicle_icon.dart';
import '../telemetry/pairing_wizard.dart';
import '../telemetry/scanner_registry.dart';

/// The speedometer button's menu: read from this record's own adapter,
/// pair one, or type the miles in.
Future<void> showMilesSourceSheet(BuildContext context, ServiceRecord record,
    void Function(ServiceRecord) onUpdated) {
  final paired = record.scanner.isNotEmpty;
  final scannerLabel = paired
      ? ScannerRegistry.byId(record.scanner['id'] as String? ?? 'generic-elm327').label
      : '';
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.bluetooth_audio, color: Color(0xff1fddb9)),
          title: Text(paired ? 'Read from $scannerLabel' : 'Pair an adapter'),
          subtitle: Text(paired
              ? 'Sync this ${labelForVehicleType(record.vehicleType)} automatically'
              : 'Plug the adapter in once, then syncing is one tap'),
          onTap: () async {
            Navigator.pop(sheetContext);
            await _readOrPair(context, record, onUpdated);
          },
        ),
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: const Text('Type it in'),
          subtitle: const Text('Enter the miles yourself'),
          onTap: () async {
            Navigator.pop(sheetContext);
            final updated = await Navigator.push<ServiceRecord>(context,
                MaterialPageRoute(builder: (_) => MilesUpdatePage(record: record)));
            if (updated != null) onUpdated(updated);
          },
        ),
        const SizedBox(height: 12),
      ]),
    ),
  );
}

Future<void> _readOrPair(BuildContext context, ServiceRecord record,
    void Function(ServiceRecord) onUpdated) async {
  if (record.scanner.isEmpty) {
    final updated = await Navigator.push<ServiceRecord>(context,
        MaterialPageRoute(builder: (_) => PairingWizard(record: record)));
    if (updated != null) onUpdated(updated);
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  try {
    final updated = await ScanSync().syncNow(record);
    onUpdated(updated);
    messenger.showSnackBar(SnackBar(
        content: Text('${updated.vehicleNumber.isEmpty ? 'Vehicle' : updated.vehicleNumber} '
            'synced: ${updated.miles?.toStringAsFixed(0)} miles ✓')));
  } catch (err) {
    messenger.showSnackBar(SnackBar(content: Text('$err')));
  }
}
