import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../records/service_record.dart';

/// Local copy of the record being edited. Kept until a save succeeds, so a
/// closed tab or a failed request never loses the last keystrokes.
class DraftStore {
  static const _prefix = 'record_draft_';

  static Future<void> write(ServiceRecord record) async {
    if (record.id.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix${record.id}', jsonEncode(record.toJson()));
  }

  static Future<ServiceRecord?> read(String id) async {
    if (id.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$id');
    if (raw == null) return null;
    try {
      return ServiceRecord.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear(String id) async {
    if (id.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$id');
  }
}
