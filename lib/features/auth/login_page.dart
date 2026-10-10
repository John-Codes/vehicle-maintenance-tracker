import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_controller.dart';
import 'brand_header.dart';

/// Basic auth UI: email/password sign in + Google button.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  var register = false;
  var busy = false;

  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }

  Future<void> submit() async {
    setState(() => busy = true);
    try {
      if (register) {
        await AuthController.instance.register(email.text.trim(), password.text);
      } else {
        await AuthController.instance.signIn(email.text.trim(), password.text);
      }
    } on FirebaseAuthException catch (err) {
      _showError(err.message ?? 'Sign in failed');
    } catch (err) {
      _showError('$err');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> google() async {
    setState(() => busy = true);
    try {
      await AuthController.instance.signInWithGoogle();
    } catch (err) {
      _showError('$err');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Fleet Tracker')),
        body: Center(
          child: ListView(shrinkWrap: true, padding: const EdgeInsets.all(32), children: [
            const BrandHeader(),
            const SizedBox(height: 36),
            TextField(controller: email, keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline))),
            const SizedBox(height: 28),
            TextField(controller: password, obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
            const SizedBox(height: 44),
            FilledButton(
              onPressed: busy ? null : submit,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
              child: Text(busy ? 'Please wait…' : (register ? 'Create account' : 'Sign in')),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: busy ? null : () => setState(() => register = !register),
              child: Text(register ? 'I already have an account' : 'Create an account'),
            ),
            const Divider(height: 64),
            OutlinedButton.icon(
              onPressed: busy ? null : google,
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
              icon: Image.asset('assets/google_logo.png', width: 26, height: 26),
              label: const Text('Continue with Google'),
            ),
          ]),
        ),
      );
}
