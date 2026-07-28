import 'package:flutter/foundation.dart';

class AppConfig {
  static const _providedUrl = String.fromEnvironment('API_URL', defaultValue: '');
  static String get apiUrl => _providedUrl.isNotEmpty
      ? _providedUrl
      : kIsWeb
          ? 'https://your-backend.onrender.com'
          : 'http://10.0.2.2:8010';
  static const apiKey = String.fromEnvironment('API_KEY', defaultValue: 'your-api-key');
}
