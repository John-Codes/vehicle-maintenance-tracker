import 'package:flutter/material.dart';
import '../records/service_record.dart';
import '../service_types/service_type.dart';

// UI label: "vehicle/equipment type" — the data field is still `service_type` (API: /service-types).
// Renamed at the UI level only, per BRANCH_UPDATE_RULES; no backend/data changes.

/// Asks whether the current checklist should be replaced when a service type
/// is chosen. Returns true for empty checklists (no confirmation needed).
Future<bool> askReplaceSchedule(BuildContext context, ServiceRecord record, ServiceType type) async {
  if (record.schedule.leaves.isEmpty) return true;
  final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
        title: Text('Use ${type.name} schedule?'),
        content: const Text('Replace the current checklist with that vehicle/equipment type?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Use')),
        ],
      ));
  return confirmed ?? false;
}
