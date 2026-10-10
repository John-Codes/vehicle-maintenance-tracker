import 'package:flutter/material.dart';

import 'auth_controller.dart';
import 'session_store.dart';

/// Pending users land here: enter (or auto-fill) a manager's invite code.
class InviteRedeemPage extends StatefulWidget {
  const InviteRedeemPage({super.key});
  @override
  State<InviteRedeemPage> createState() => _InviteRedeemPageState();
}

class _InviteRedeemPageState extends State<InviteRedeemPage> {
  final code = TextEditingController();
  var busy = false;

  @override
  void initState() {
    super.initState();
    _autoRedeemCapturedCode();
  }

  /// Someone opened an ?invite=CODE link: prefill and redeem immediately.
  Future<void> _autoRedeemCapturedCode() async {
    final captured = await SessionStore.inviteCode();
    if (captured == null || captured.isEmpty) return;
    code.text = captured;
    if (mounted) await redeem();
  }

  @override
  void dispose() { code.dispose(); super.dispose(); }

  Future<void> redeem() async {
    if (code.text.trim().isEmpty) return;
    setState(() => busy = true);
    try {
      await AuthController.instance.redeemInvite(code.text.trim());
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$err')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> signOut() async {
    setState(() => busy = true);
    await AuthController.instance.signOut();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Join your team'), automaticallyImplyLeading: false),
        body: Center(
          child: ListView(shrinkWrap: true, padding: const EdgeInsets.all(24), children: [
            const Icon(Icons.group_add_outlined, size: 64),
            const SizedBox(height: 12),
            Text('Signed in as ${AuthController.instance.user?.email ?? ''}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            const Text('Ask a manager for an invite link, then enter the code here.',
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextField(controller: code,
                decoration: const InputDecoration(labelText: 'Invite code', prefixIcon: Icon(Icons.key))),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: busy ? null : redeem,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(busy ? 'Please wait…' : 'Join team'),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: busy ? null : signOut, child: const Text('Sign out')),
          ]),
        ),
      );
}
