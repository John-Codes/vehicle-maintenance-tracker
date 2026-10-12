import 'package:flutter/material.dart';

/// Icon per vehicle type so every record row shows what it is.
IconData iconForVehicleType(String type) {
  switch (type) {
    case 'car':
      return Icons.directions_car_outlined;
    case 'truck':
      return Icons.local_shipping_outlined;
    case 'heavy_equipment':
      return Icons.construction_outlined;
    case 'motorcycle':
      return Icons.motorcycle_outlined;
    case 'other':
      return Icons.help_outline;
    default:
      return Icons.build_outlined;
  }
}

/// Human label per vehicle type, used in the telemetry wording.
String labelForVehicleType(String type) {
  switch (type) {
    case 'car':
      return 'car';
    case 'truck':
      return 'truck';
    case 'heavy_equipment':
      return 'equipment';
    case 'motorcycle':
      return 'motorcycle';
    case 'other':
      return 'vehicle';
    default:
      return 'vehicle';
  }
}
