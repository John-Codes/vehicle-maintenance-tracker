import '../../core/api_client.dart';

class Invite {
  final String id, code, role;
  const Invite({required this.id, required this.code, required this.role});

  factory Invite.fromJson(Map<String, dynamic> json) => Invite(
        id: (json['id'] ?? '').toString(),
        code: (json['code'] ?? '').toString(),
        role: (json['role'] ?? 'tech').toString(),
      );
}

class InvitesRepository {
  final ApiClient _api;
  InvitesRepository([ApiClient? api]) : _api = api ?? ApiClient();

  Future<Invite> create(String role) async =>
      Invite.fromJson(Map<String, dynamic>.from(await _api.post('/invites', {'role': role})));

  Future<List<Invite>> list() async => (await _api.get('/invites') as List)
      .map((x) => Invite.fromJson(Map<String, dynamic>.from(x)))
      .toList();

  Future<void> revoke(String inviteId) async => _api.delete('/invites/$inviteId');
}
