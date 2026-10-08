import 'package:geolocator/geolocator.dart';

class LocationFix {
  final double lat, lng, accuracy;
  const LocationFix({required this.lat, required this.lng, required this.accuracy});
}

LocationFix? _cached;
DateTime? _cachedAt;

/// Best-effort device location. Returns null when denied, unavailable or on a
/// plain-HTTP origin so marking something done is never blocked by location.
Future<LocationFix?> captureLocation() async {
  final now = DateTime.now();
  if (_cached != null && _cachedAt != null && now.difference(_cachedAt!) < const Duration(seconds: 60)) {
    return _cached;
  }
  try {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return null;
    final position = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 5));
    _cached = LocationFix(lat: position.latitude, lng: position.longitude, accuracy: position.accuracy);
    _cachedAt = now;
    return _cached;
  } catch (_) {
    return null;
  }
}
