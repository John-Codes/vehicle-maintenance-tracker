import 'dart:convert';
import 'dart:typed_data';

import '../../core/api_client.dart';
import 'chat_message.dart';

/// Talks to the backend `POST /chat` endpoint. The server injects the
/// workspace's service records as context, so the client only sends the
/// conversation. Photos are sent base64; the server verifies the EXIF date
/// (strict same-day) and discards them - they are never stored.
class ChatApi {
  final ApiClient _api;
  ChatApi([ApiClient? api]) : _api = api ?? ApiClient();

  Future<String> ask(String message, List<ChatMessage> history,
      {Uint8List? photo}) async {
    final body = <String, dynamic>{
      'message': message,
      'history': [
        for (final item in history)
          {'role': item.isUser ? 'user' : 'assistant', 'content': item.text},
      ],
      if (photo != null) 'images': [base64Encode(photo)],
    };
    final reply = await _api.post('/chat', body);
    if (reply is Map && reply['reply'] != null) return reply['reply'].toString();
    return '';
  }

  /// The signed-in user's private saved thread (oldest first).
  Future<List<ChatMessage>> loadHistory() async {
    final reply = await _api.get('/chat/history');
    final messages = (reply is Map) ? reply['messages'] : null;
    if (messages is! List) return [];
    return [
      for (final item in messages)
        if (item is Map) ChatMessage.fromHistory(Map<String, dynamic>.from(item)),
    ];
  }

  Future<void> clearHistory() => _api.delete('/chat/history');
}
