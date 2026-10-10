import 'package:flutter/foundation.dart';

import '../../core/api_client.dart';

class Invite {
  final String id, code, role, label;
  const Invite({required this.id, required this.code, required this.role, required this.label});

  factory Invite.fromJson(Map<String, dynamic> json) => Invite(
        id: (json['id'] ?? '').toString(),
        code: (json['code'] ?? '').toString(),
        role: (json['role'] ?? 'tech').toString(),
        label: (json['label'] ?? '').toString(),
      );
}

/// A full shareable link on web (e.g. http://host:8097/?invite=CODE),
/// or the bare code everywhere else.
String inviteLink(String code) {
  final uri = Uri.base;
  if (kIsWeb && uri.hasAuthority) {
    return uri.replace(path: '/', queryParameters: {'invite': code}).toString();
  }
  return code;
}

class InvitesRepository {
  final ApiClient _api;
  InvitesRepository([ApiClient? api]) : _api = api ?? ApiClient();

  Future<Invite> create(String role, String label) async =>
      Invite.fromJson(Map<String, dynamic>.from(
          await _api.post('/invites', {'role': role, 'label': label})));

  Future<List<Invite>> list() async => (await _api.get('/invites') as List)
      .map((x) => Invite.fromJson(Map<String, dynamic>.from(x)))
      .toList();

  Future<void> revoke(String inviteId) async => _api.delete('/invites/$inviteId');
}
