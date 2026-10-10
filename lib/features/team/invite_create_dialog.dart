import 'package:flutter/material.dart';

/// Asks who the invite is for (optional name/email) and which role they get.
/// Returns (label, role), or null when cancelled.
class InviteCreateDialog extends StatefulWidget {
  final String initialRole;
  const InviteCreateDialog({super.key, required this.initialRole});

  @override
  State<InviteCreateDialog> createState() => _InviteCreateDialogState();
}

class _InviteCreateDialogState extends State<InviteCreateDialog> {
  final label = TextEditingController();
  late String role;

  @override
  void initState() {
    super.initState();
    role = widget.initialRole;
  }

  @override
  void dispose() {
    label.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, (label.text.trim(), role));

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('New invite'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: label,
            autofocus: true,
            decoration: const InputDecoration(
                labelText: 'Invitee name or email',
                hintText: 'e.g. Carlos or carlos@safeprevent.com'),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: role,
            decoration: const InputDecoration(labelText: 'Role'),
            items: const [
              DropdownMenuItem(value: 'tech', child: Text('Technician')),
              DropdownMenuItem(value: 'manager', child: Text('Manager')),
            ],
            onChanged: (value) => setState(() => role = value ?? 'tech'),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: _submit, child: const Text('Create invite')),
        ],
      );
}
