class AuthUser {
  final String id;
  final String email;
  final String name;
  final String role;
  final String workspaceId;

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.workspaceId,
  });

  bool get isManager => role == 'manager';
  bool get hasWorkspace => workspaceId.isNotEmpty;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: (json['id'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        role: (json['role'] ?? 'tech').toString(),
        workspaceId: (json['workspace_id'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'email': email, 'name': name, 'role': role, 'workspace_id': workspaceId};
}
