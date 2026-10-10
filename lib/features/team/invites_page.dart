import 'package:flutter/material.dart';

import '../../core/clipboard_copy.dart';
import '../../core/cold_start_notice.dart';
import 'invite_create_dialog.dart';
import 'invite_created_dialog.dart';
import 'invites_repository.dart';

/// Manager-only: create labeled single-use invite links, copy, revoke.
class InvitesPage extends StatefulWidget {
  const InvitesPage({super.key});
  @override
  State<InvitesPage> createState() => _InvitesPageState();
}

class _InvitesPageState extends State<InvitesPage> {
  final repo = InvitesRepository();
  late Future<List<Invite>> invites;
  String newRole = 'tech';

  @override
  void initState() { super.initState(); invites = repo.list(); }
  void refresh() => setState(() => invites = repo.list());

  Future<void> copyLink(String code) async {
    final link = inviteLink(code);
    final copied = await copyText(link);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(copied ? 'Invite link copied' : 'Copy blocked — link: $link')));
    }
  }

  Future<void> create() async {
    final result = await showDialog<(String, String)>(context: context,
        builder: (_) => InviteCreateDialog(initialRole: newRole));
    if (result == null) return;
    final (label, role) = result;
    newRole = role;
    final invite = await repo.create(role, label);
    refresh();
    final link = inviteLink(invite.code);
    final copied = await copyText(link);
    if (mounted) {
      await showDialog(context: context, builder: (_) =>
          InviteCreatedDialog(invite: invite, link: link, copied: copied));
    }
    refresh();
  }

  Future<void> revoke(Invite invite) async {
    await repo.revoke(invite.id);
    refresh();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Invite links')),
    body: Column(children: [
      Padding(padding: const EdgeInsets.all(20), child: FilledButton.icon(
          onPressed: create, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          icon: const Icon(Icons.person_add_alt_outlined), label: const Text('Create invite'))),
      Expanded(child: FutureBuilder<List<Invite>>(future: invites, builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) return const ColdStartNotice();
        if (snap.hasError) return Center(child: Text('${snap.error}'));
        if (snap.data!.isEmpty) return const Center(child: Text('No active invites. Create one to add people.'));
        return ListView.builder(itemCount: snap.data!.length, itemBuilder: (_, i) {
          final invite = snap.data![i];
          final title = invite.label.isEmpty ? 'Unnamed invite' : invite.label;
          return ListTile(
            leading: Icon(invite.role == 'manager' ? Icons.admin_panel_settings_outlined : Icons.person_outline),
            title: Text(title),
            subtitle: Text('${invite.role == 'manager' ? 'Manager' : 'Technician'} · ${invite.code}'),
            trailing: IconButton(icon: const Icon(Icons.copy), onPressed: () => copyLink(invite.code)),
            onLongPress: () => revoke(invite),
          );
        });
      })),
    ]),
  );
}
