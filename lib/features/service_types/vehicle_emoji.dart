// UI-level glue: emojis for vehicle/equipment types.
// NOTE: the data field is still `service_type` (API: /service-types,
// collection: service_types). "Vehicle/equipment type" is a UI label only —
// renamed at the UI layer per BRANCH_UPDATE_RULES; no backend/data changes.

/// Resolves the emoji for a record or a vehicle/equipment type name.
/// 1. An explicit vehicle_type (from the Add car/truck/equipment button)
///    always wins. 2. Otherwise we infer from the type name keywords.
/// 3. No match falls back to the toolbox.
String vehicleEmojiFor({
  String vehicleType = '',
  String vehicleTypeName = '',
}) {
  switch (vehicleType) {
    case 'car':
      return '🚗';
    case 'truck':
      return '🚚';
    case 'heavy_equipment':
      return '🚜';
    case 'motorcycle':
      return '🏍️';
    case 'other':
      return '🔧';
  }
  final name = vehicleTypeName.toLowerCase();
  if (name.contains('semi')) return '🚛';
  if (name.contains('trailer')) return '🚚';
  if (name.contains('reclaimer') ||
      name.contains('excavator') ||
      name.contains('dozer') ||
      name.contains('equipment') ||
      name.contains('vermeer')) {
    return '🚜';
  }
  if (name.contains('pump')) return '🛢️';
  if (name.contains('motorcycle') || name.contains('bike')) return '🏍️';
  if (name.contains('car')) return '🚗';
  if (name.contains('truck')) return '🚚';
  return '🧰';
}
