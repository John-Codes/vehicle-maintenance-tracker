import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/api_client.dart';
import 'auth_repository.dart';
import 'auth_user.dart';
import 'session_store.dart';

/// App-wide session state. Firebase supplies identity; the tracker backend
/// supplies the session token, role, and workspace.
class AuthController extends ChangeNotifier {
  static final AuthController instance = AuthController._();
  AuthController._() {
    FirebaseAuth.instance.idTokenChanges().listen(_onFirebaseUser);
  }

  final _repo = AuthRepository();
  AuthUser? user;
  bool busy = true;

  /// Capture an invite code shared as ?invite=CODE and finish restoring state.
  Future<void> bootstrap() async {
    final invite = Uri.base.queryParameters['invite'] ?? '';
    if (invite.isNotEmpty) await SessionStore.saveInviteCode(invite);
    final token = await SessionStore.token();
    if (token != null) ApiClient.bearerToken = token;
    busy = false;
    notifyListeners();
  }

  Future<void> _onFirebaseUser(User? fbUser) async {
    if (fbUser == null) {
      ApiClient.bearerToken = null;
      await SessionStore.clear();
      user = null;
      notifyListeners();
      return;
    }
    try {
      final idToken = await fbUser.getIdToken() ?? '';
      user = await _repo.exchangeFirebaseToken(idToken);
      final token = ApiClient.bearerToken;
      if (token != null && user != null) await SessionStore.save(token, user!);
    } catch (_) {/* offline or backend asleep; keep stored session */}
    notifyListeners();
  }

  Future<void> signIn(String email, String password) =>
      FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);

  Future<void> register(String email, String password) =>
      FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, password: password);

  Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    if (kIsWeb) {
      await FirebaseAuth.instance.signInWithPopup(provider);
    } else {
      await FirebaseAuth.instance.signInWithProvider(provider);
    }
  }

  Future<void> redeemInvite(String code) async {
    user = await _repo.redeemInvite(code);
    await SessionStore.clearInviteCode();
    notifyListeners();
  }

  Future<void> refreshFromBackend() async {
    user = await _repo.currentUser();
    notifyListeners();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    user = null;
    ApiClient.bearerToken = null;
    await SessionStore.clear();
    notifyListeners();
  }
}
