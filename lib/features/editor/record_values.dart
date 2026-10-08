import 'package:flutter/widgets.dart';
import '../records/service_record.dart';

/// Collects the edited form fields into a ServiceRecord for saving or export.
ServiceRecord buildRecordValues(
  ServiceRecord record, {
  required TextEditingController vehicle,
  required TextEditingController vin,
  required TextEditingController plate,
  required TextEditingController miles,
  required TextEditingController hours,
  required TextEditingController service,
  required TextEditingController workers,
  required TextEditingController notes,
  required TextEditingController next,
}) =>
    record.copyWith(
      vehicleNumber: vehicle.text,
      vin: vin.text,
      licensePlate: plate.text,
      serviceType: service.text,
      miles: num.tryParse(miles.text),
      hours: num.tryParse(hours.text),
      workerNames: workers.text.split(',').map((x) => x.trim()).where((x) => x.isNotEmpty).toList(),
      notes: notes.text,
      nextSteps: next.text,
    );
