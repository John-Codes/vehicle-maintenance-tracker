import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class ApiClient {
  final http.Client _client;
  ApiClient([http.Client? client]) : _client = client ?? http.Client();

  static const _backoffSeconds = [5, 10, 20, 30, 30];
  static final coldStart = ValueNotifier<bool>(false);

  Future<dynamic> get(String path) => _send('GET', path);
  Future<dynamic> post(String path, [Object? body]) => _send('POST', path, body);
  Future<dynamic> put(String path, Object body) => _send('PUT', path, body);
  Future<void> delete(String path) async => _send('DELETE', path);

  Future<dynamic> _send(String method, String path, [Object? body]) async {
    for (var attempt = 0; attempt <= _backoffSeconds.length; attempt++) {
      try {
        final request = http.Request(method, Uri.parse('${AppConfig.apiUrl}$path'));
        request.headers.addAll({'X-App-Key': AppConfig.apiKey, 'Content-Type': 'application/json'});
        if (body != null) request.body = jsonEncode(body);
        final response = await http.Response.fromStream(await _client.send(request));
        final retryable = response.statusCode == 429 || response.statusCode >= 500;
        if (retryable && attempt < _backoffSeconds.length) {
          coldStart.value = true;
          await Future.delayed(Duration(seconds: _backoffSeconds[attempt]));
          continue;
        }
        coldStart.value = false;
        if (response.statusCode >= 400) throw Exception(_message(response));
        return response.body.isEmpty ? null : jsonDecode(response.body);
      } catch (_) {
        coldStart.value = false;
        rethrow;
      }
    }
  }

  String _message(http.Response response) {
    try { return jsonDecode(response.body)['detail'].toString(); } catch (_) { return 'Request failed (${response.statusCode})'; }
  }
}
