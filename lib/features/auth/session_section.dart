import 'package:flutter/material.dart';

import '../team/invites_page.dart';
import '../team/team_page.dart';
import 'auth_controller.dart';

/// Signed-in user card, manager-only team links, and sign out.
/// Hidden entirely when running on the legacy shared key.
class SessionSection extends StatelessWidget {
  const SessionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();
    final managerTools = <Widget>[
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TeamPage())),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        icon: const Icon(Icons.group_outlined),
        label: const Text('Manage team'),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const InvitesPage())),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        icon: const Icon(Icons.person_add_alt_outlined),
        label: const Text('Invite links'),
      ),
    ];
    return Column(children: [
      Card(child: ListTile(
        leading: const Icon(Icons.account_circle_outlined),
        title: Text(user.email),
        subtitle: Text(user.isManager
            ? 'Manager · workspace ${user.workspaceId}'
            : 'Technician · workspace ${user.workspaceId}'),
      )),
      if (user.isManager) ...managerTools,
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: auth.signOut,
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        icon: const Icon(Icons.logout),
        label: const Text('Sign out'),
      ),
      const SizedBox(height: 12),
    ]);
  }
}
