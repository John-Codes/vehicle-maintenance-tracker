import '../../core/api_client.dart';
import 'auth_user.dart';

class AuthRepository {
  final ApiClient _api;
  AuthRepository([ApiClient? api]) : _api = api ?? ApiClient();

  /// Exchange a Firebase ID token for the tracker session (token + user).
  Future<AuthUser> exchangeFirebaseToken(String idToken) async {
    final data = Map<String, dynamic>.from(
        (await _api.post('/auth/firebase', {'id_token': idToken})) as Map);
    ApiClient.bearerToken = data['access_token'] as String;
    return AuthUser.fromJson(Map<String, dynamic>.from(data['user']));
  }

  Future<AuthUser> currentUser() async =>
      AuthUser.fromJson(Map<String, dynamic>.from(await _api.get('/auth/me')));

  /// Consume an invite code; the backend joins this user to the workspace.
  Future<AuthUser> redeemInvite(String code) async =>
      AuthUser.fromJson(Map<String, dynamic>.from(
          await _api.post('/invites/redeem', {'code': code})));
}
