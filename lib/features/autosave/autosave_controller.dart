import 'dart:async';
import 'package:flutter/widgets.dart';
import '../records/records_repository.dart';
import '../records/service_record.dart';
import 'draft_store.dart';

/// Debounced silent save for the record editor.
/// touch()  -> write a local draft now, PUT after 1s without further changes.
/// flush()  -> PUT immediately (used when checklist state changes).
/// restore()-> re-apply a leftover draft and send it to the backend right away.
class AutosaveController {
  final ServiceRecord Function() value;
  final RecordsRepository repo;
  Timer? _timer;
  bool _saving = false;
  AutosaveController({required this.value, required this.repo});

  void watch(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      controller.addListener(touch);
    }
  }

  void touch() {
    DraftStore.write(value());
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 1), flush);
  }

  Future<void> flush() async {
    _timer?.cancel();
    final record = value();
    if (record.id.isEmpty) return;
    if (_saving) {
      _timer = Timer(const Duration(seconds: 1), flush);
      return;
    }
    _saving = true;
    try {
      await repo.save(record);
      await DraftStore.clear(record.id);
    } catch (_) {
      // Keep the local draft; the next change or editor open retries the save.
    } finally {
      _saving = false;
    }
  }

  Future<bool> restore(String recordId, void Function(ServiceRecord) apply) async {
    final draft = await DraftStore.read(recordId);
    if (draft == null) return false;
    apply(draft);
    await flush();
    return true;
  }

  Future<void> clearDraft(String id) => DraftStore.clear(id);

  void dispose() => _timer?.cancel();
}
