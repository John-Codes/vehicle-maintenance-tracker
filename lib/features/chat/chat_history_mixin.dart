import 'package:flutter/foundation.dart';

import '../../core/api_client.dart';
import 'chat_api.dart';
import 'chat_message.dart';

/// Server-side chat history for the signed-in user: auto-loads once a session
/// token exists (retried on every auth change because the chat tab can be
/// built before sign-in finishes), plus manual reload and clear.
mixin ChatHistoryMixin on ChangeNotifier {
  final ChatApi _historyApi = ChatApi();
  bool _historyLoaded = false;

  /// Provided by ChatLogic: the visible message list and the greeting reset.
  List<ChatMessage> get messages;
  void resetToGreeting();

  void onAuthChanged() {
    if (ApiClient.bearerToken == null) {
      _historyLoaded = false;
      resetToGreeting();
      notifyListeners();
      return;
    }
    loadHistory();
  }

  /// Pull the saved thread once per session. Does not latch while signed out
  /// or on failure, so the next sign-in retries.
  Future<void> loadHistory() async {
    if (_historyLoaded || ApiClient.bearerToken == null) return;
    try {
      final history = await _historyApi.loadHistory();
      _historyLoaded = true;
      if (history.isNotEmpty) _show(history);
    } catch (_) {
      // History is a convenience; chat still works without it.
    }
  }

  /// Force a refresh from the server; returns how many messages came back.
  /// Keeps the current view when there is nothing saved yet.
  Future<int> reloadHistory() async {
    final history = await _historyApi.loadHistory();
    _historyLoaded = true;
    if (history.isNotEmpty) _show(history);
    return history.length;
  }

  /// Wipe the server-side thread and reset this view to the greeting.
  Future<void> clearHistory() async {
    await _historyApi.clearHistory();
    _historyLoaded = true;
    resetToGreeting();
    notifyListeners();
  }

  void _show(List<ChatMessage> history) {
    messages
      ..clear()
      ..addAll(history);
    notifyListeners();
  }
}
