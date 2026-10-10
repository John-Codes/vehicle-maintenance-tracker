import 'package:flutter/material.dart';

import '../../core/clipboard_copy.dart';
import 'invites_repository.dart';

/// Success dialog: the whole link is selectable, plus a copy button that
/// works even over plain http (execCommand fallback).
class InviteCreatedDialog extends StatelessWidget {
  final Invite invite;
  final String link;
  final bool copied;

  const InviteCreatedDialog(
      {super.key, required this.invite, required this.link, required this.copied});

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Invite for ${invite.label.isEmpty ? 'new member' : invite.label}'),
    content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(copied ? 'Invite link copied to clipboard.' : 'Clipboard blocked — select and copy the link below.'),
      const SizedBox(height: 16),
      SelectableText(link, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('Code: ${invite.code} (role: ${invite.role == 'manager' ? 'Manager' : 'Technician'})',
          style: const TextStyle(fontSize: 13)),
    ]),
    actions: [
      TextButton(onPressed: () async {
        final ok = await copyText(link);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(ok ? 'Copied' : 'Still blocked — select the text above')));
        }
      }, child: const Text('Copy link')),
      FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
    ],
  );
}
