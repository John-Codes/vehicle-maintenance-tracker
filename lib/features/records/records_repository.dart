import '../../core/api_client.dart';
import 'service_record.dart';

class RecordsRepository {
  final ApiClient _api;
  RecordsRepository([ApiClient? api]) : _api = api ?? ApiClient();
  Future<List<ServiceRecord>> list({String search = ''}) async {
    final path = search.trim().isEmpty ? '/service-records' : '/service-records?search=${Uri.encodeQueryComponent(search.trim())}';
    return (await _api.get(path) as List).map((x) => ServiceRecord.fromJson(Map<String, dynamic>.from(x))).toList();
  }
  Future<ServiceRecord> create() async => ServiceRecord.fromJson(await _api.post('/service-records'));
  Future<ServiceRecord> save(ServiceRecord record) async => ServiceRecord.fromJson(await _api.put('/service-records/${record.id}', record.toJson()));
  Future<void> delete(String id) => _api.delete('/service-records/$id');
}
