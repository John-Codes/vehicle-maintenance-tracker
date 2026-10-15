import 'package:flutter/foundation.dart';

import '../../core/api_client.dart';
import 'chat_api.dart';
import 'chat_message.dart';

/// Server-side conversation history, one TOPIC per thread, private per user.
/// Auto-continues the newest thread on sign-in; manual open/new/delete.
mixin ChatHistoryMixin on ChangeNotifier {
  final ChatApi _historyApi = ChatApi();
  bool _historyLoaded = false;

  /// The thread the current view belongs to ('' = brand-new conversation).
  String currentTopicId = '';

  /// Provided by ChatLogic: the visible message list and the greeting reset.
  List<ChatMessage> get messages;
  void resetToGreeting();

  void onAuthChanged() {
    if (ApiClient.bearerToken == null) {
      _historyLoaded = false;
      currentTopicId = '';
      resetToGreeting();
      notifyListeners();
      return;
    }
    loadHistory();
  }

  /// Continue where the user left off: open their newest thread, if any.
  /// Does not latch while signed out or on failure, so sign-in retries.
  Future<void> loadHistory() async {
    if (_historyLoaded || ApiClient.bearerToken == null) return;
    try {
      final topics = await _historyApi.loadTopics();
      _historyLoaded = true;
      if (topics.isNotEmpty) await openTopic(topics.first.topicId);
    } catch (_) {
      // History is a convenience; chat still works without it.
    }
  }

  /// List the user's threads for the history widget, newest activity first.
  Future<List<ChatTopic>> loadTopicList() => _historyApi.loadTopics();

  /// Show a past thread and continue it on the next send.
  Future<void> openTopic(String topicId) async {
    final history = await _historyApi.loadTopic(topicId);
    currentTopicId = topicId;
    messages
      ..clear()
      ..addAll(history);
    notifyListeners();
  }

  /// Start a fresh conversation (the previous thread stays saved server-side).
  void newConversation() {
    currentTopicId = '';
    resetToGreeting();
    notifyListeners();
  }

  /// The server assigns the thread id on the first reply of a new topic.
  void onTurnFinished(String topicId) {
    if (topicId.isNotEmpty && topicId != currentTopicId) currentTopicId = topicId;
  }

  /// Delete one thread; reset the view if it was the open one.
  Future<void> deleteTopic(String topicId) async {
    await _historyApi.deleteTopic(topicId);
    if (topicId == currentTopicId) newConversation();
  }

  /// Wipe every thread of this user in this workspace.
  Future<void> clearHistory() async {
    await _historyApi.clearHistory();
    _historyLoaded = true;
    newConversation();
  }
}
