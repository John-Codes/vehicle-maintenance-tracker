import 'package:flutter/material.dart';

import '../../app/home_shell.dart';
import '../../core/cold_start_notice.dart';
import 'auth_controller.dart';
import 'invite_redeem_page.dart';
import 'login_page.dart';

/// Routes by session state: signed out -> login, pending -> invite redeem,
/// active -> the app shell.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    AuthController.instance.bootstrap();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: AuthController.instance,
        builder: (context, child) {
          final auth = AuthController.instance;
          if (auth.busy) return const Scaffold(body: ColdStartNotice());
          final user = auth.user;
          if (user == null) return const LoginPage();
          if (!user.hasWorkspace) return const InviteRedeemPage();
          return const HomeShell();
        },
      );
}
