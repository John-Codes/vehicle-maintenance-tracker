import '../../core/api_client.dart';

class TeamMember {
  final String id, email, name, role;
  const TeamMember({required this.id, required this.email, required this.name, required this.role});

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        id: (json['id'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        role: (json['role'] ?? 'tech').toString(),
      );

  bool get isManager => role == 'manager';
}

class TeamRepository {
  final ApiClient _api;
  TeamRepository([ApiClient? api]) : _api = api ?? ApiClient();

  Future<List<TeamMember>> list() async => (await _api.get('/users') as List)
      .map((x) => TeamMember.fromJson(Map<String, dynamic>.from(x)))
      .toList();

  Future<TeamMember> setRole(String userId, String role) async =>
      TeamMember.fromJson(Map<String, dynamic>.from(
          await _api.put('/users/$userId/role', {'role': role})));

  Future<void> remove(String userId) async => _api.delete('/users/$userId');
}
