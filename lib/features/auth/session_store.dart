import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'auth_user.dart';

/// Persists the tracker session token and the pending invite code.
class SessionStore {
  static const _tokenKey = 'tracker_token';
  static const _userKey = 'tracker_user';
  static const _inviteKey = 'pending_invite_code';

  static Future<void> save(String token, AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<String?> token() async =>
      (await SharedPreferences.getInstance()).getString(_tokenKey);

  static Future<AuthUser?> user() async {
    final raw = (await SharedPreferences.getInstance()).getString(_userKey);
    if (raw == null || raw.isEmpty) return null;
    return AuthUser.fromJson(Map<String, dynamic>.from(jsonDecode(raw)));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  static Future<void> saveInviteCode(String code) async =>
      (await SharedPreferences.getInstance()).setString(_inviteKey, code);

  static Future<String?> inviteCode() async =>
      (await SharedPreferences.getInstance()).getString(_inviteKey);

  static Future<void> clearInviteCode() async =>
      (await SharedPreferences.getInstance()).remove(_inviteKey);
}
