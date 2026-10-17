import 'dart:convert';
import 'dart:typed_data';

import '../../core/api_client.dart';
import 'chat_message.dart';

/// One chat turn: the assistant reply plus the conversation thread it
/// belongs to (the server auto-titles new threads from the first message).
class ChatTurn {
  final String reply;
  final String topicId;
  const ChatTurn({required this.reply, required this.topicId});
}

/// One conversation thread in the user's private history.
class ChatTopic {
  final String topicId;
  final String title;
  final DateTime updatedAt;
  const ChatTopic({required this.topicId, required this.title, required this.updatedAt});

  factory ChatTopic.fromJson(Map<String, dynamic> item) => ChatTopic(
        topicId: (item['topic_id'] ?? '').toString(),
        title: (item['title'] ?? 'Conversation').toString(),
        updatedAt: DateTime.tryParse((item['updated_at'] ?? '').toString()) ?? DateTime.now(),
      );
}

/// Talks to the backend chat endpoints. The server injects the workspace's
/// service records as context, so the client only sends the conversation.
/// Photos are sent base64; the server verifies the EXIF date (strict
/// same-day) and discards them - they are never stored.
class ChatApi {
  final ApiClient _api;
  ChatApi([ApiClient? api]) : _api = api ?? ApiClient();

  Future<ChatTurn> ask(String message, List<ChatMessage> history,
      {Uint8List? photo, String? topicId}) async {
    final body = <String, dynamic>{
      'message': message,
      'history': [
        for (final item in history)
          {'role': item.isUser ? 'user' : 'assistant', 'content': item.text},
      ],
      if (photo != null) 'images': [base64Encode(photo)],
      if (topicId != null && topicId.isNotEmpty) 'topic_id': topicId,
    };
    final reply = await _api.post('/chat', body);
    if (reply is! Map) return const ChatTurn(reply: '', topicId: '');
    return ChatTurn(
      reply: (reply['reply'] ?? '').toString(),
      topicId: (reply['topic_id'] ?? '').toString(),
    );
  }

  /// The signed-in user's threads, newest activity first.
  Future<List<ChatTopic>> loadTopics() async {
    final reply = await _api.get('/chat/history');
    final topics = (reply is Map) ? reply['topics'] : null;
    if (topics is! List) return [];
    return [
      for (final item in topics)
        if (item is Map) ChatTopic.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  /// One thread's messages (oldest first). Private to its owner.
  Future<List<ChatMessage>> loadTopic(String topicId) async {
    final reply = await _api.get('/chat/history/$topicId');
    final messages = (reply is Map) ? reply['messages'] : null;
    if (messages is! List) return [];
    return [
      for (final item in messages)
        if (item is Map) ChatMessage.fromHistory(Map<String, dynamic>.from(item)),
    ];
  }

  Future<void> deleteTopic(String topicId) => _api.delete('/chat/history/$topicId');

  Future<void> clearHistory() => _api.delete('/chat/history');
}
