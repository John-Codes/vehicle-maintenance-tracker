import '../../core/api_client.dart';
import 'service_type.dart';
class ServiceTypesRepository {
  final _api = ApiClient();
  Future<List<ServiceType>> list() async => (await _api.get('/service-types') as List).map((j) => ServiceType.fromJson(j)).toList();
  Future<void> save(ServiceType type) async {
    if (type.id.isEmpty) { await _api.post('/service-types', type.toJson()); }
    else { await _api.put('/service-types/${type.id}', type.toJson()); }
  }
  Future<void> delete(String id) => _api.delete('/service-types/$id');
}
