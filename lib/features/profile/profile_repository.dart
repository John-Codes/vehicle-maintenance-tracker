import '../../core/api_client.dart';
import 'technician.dart';

class ProfileRepository {
  final ApiClient _api;
  ProfileRepository([ApiClient? api]) : _api = api ?? ApiClient();
  Future<Technician> load() async => Technician.fromJson(await _api.get('/profile'));
  Future<Technician> save(Technician profile) async => Technician.fromJson(
        await _api.put('/profile', profile.toJson()));
}
