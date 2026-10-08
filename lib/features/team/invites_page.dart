import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/cold_start_notice.dart';
import 'invites_repository.dart';

/// Manager-only: create single-use invite links, copy codes, revoke.
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

  Future<void> create() async {
    final invite = await repo.create(newRole);
    await Clipboard.setData(ClipboardData(text: invite.code));
    if (mounted) {
      await showDialog(context: context, builder: (ctx) => AlertDialog(
        title: const Text('Invite created'),
        content: Text('Code: ${invite.code}\n\nCode copied to clipboard. '
            'Share it as a link:\n?invite=${invite.code}'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ));
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
      Padding(padding: const EdgeInsets.all(20), child: Row(children: [
        Expanded(child: DropdownButtonFormField<String>(
          initialValue: newRole,
          decoration: const InputDecoration(labelText: 'New member role'),
          items: const [
            DropdownMenuItem(value: 'tech', child: Text('Technician')),
            DropdownMenuItem(value: 'manager', child: Text('Manager')),
          ],
          onChanged: (value) => setState(() => newRole = value ?? 'tech'),
        )),
        const SizedBox(width: 16),
        FilledButton.icon(onPressed: create, icon: const Icon(Icons.add), label: const Text('Create')),
      ])),
      Expanded(child: FutureBuilder<List<Invite>>(future: invites, builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) return const ColdStartNotice();
        if (snap.hasError) return Center(child: Text('${snap.error}'));
        if (snap.data!.isEmpty) return const Center(child: Text('No active invites. Create one to add people.'));
        return ListView.builder(itemCount: snap.data!.length, itemBuilder: (_, i) {
          final invite = snap.data![i];
          return ListTile(
            leading: Icon(invite.role == 'manager' ? Icons.admin_panel_settings_outlined : Icons.person_outline),
            title: Text(invite.code),
            subtitle: Text('${invite.role == 'manager' ? 'Manager' : 'Technician'} invite'),
            trailing: IconButton(icon: const Icon(Icons.copy), onPressed: () =>
                Clipboard.setData(ClipboardData(text: invite.code))),
            onLongPress: () => revoke(invite),
          );
        });
      })),
    ]),
  );
}
