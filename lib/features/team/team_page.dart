import 'package:flutter/material.dart';

import '../../core/cold_start_notice.dart';
import 'team_repository.dart';

/// Manager-only: workspace user list with role changes and removal.
class TeamPage extends StatefulWidget {
  const TeamPage({super.key});
  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final repo = TeamRepository();
  late Future<List<TeamMember>> members;

  @override
  void initState() { super.initState(); members = repo.list(); }
  void refresh() => setState(() => members = repo.list());

  Future<void> changeRole(TeamMember member) async {
    final role = member.isManager ? 'tech' : 'manager';
    await repo.setRole(member.id, role);
    refresh();
  }

  Future<void> confirmRemove(TeamMember member) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Remove from team?'),
      content: Text('${member.email} loses access until re-invited.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red))),
      ],
    ));
    if (yes == true) { await repo.remove(member.id); refresh(); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Team')),
    body: FutureBuilder<List<TeamMember>>(future: members, builder: (_, snap) {
      if (snap.connectionState != ConnectionState.done) return const ColdStartNotice();
      if (snap.hasError) return Center(child: Text('${snap.error}'));
      return ListView.builder(itemCount: snap.data!.length, itemBuilder: (_, i) {
        final member = snap.data![i];
        return ListTile(
          leading: Icon(member.isManager ? Icons.admin_panel_settings_outlined : Icons.person_outline),
          title: Text(member.email),
          subtitle: Text(member.isManager ? 'Manager' : 'Technician'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            TextButton(onPressed: () => changeRole(member),
                child: Text(member.isManager ? 'Make tech' : 'Make manager')),
            IconButton(icon: const Icon(Icons.person_remove_outlined, color: Colors.red),
                onPressed: () => confirmRemove(member)),
          ]),
        );
      });
    }),
  );
}
