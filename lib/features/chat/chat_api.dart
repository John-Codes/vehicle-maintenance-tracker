import '../../core/api_client.dart';
import 'chat_message.dart';

/// Talks to the backend `POST /chat` endpoint. The server injects the
/// service records as context, so the client only sends the conversation.
class ChatApi {
  final ApiClient _api;
  ChatApi([ApiClient? api]) : _api = api ?? ApiClient();

  Future<String> ask(String message, List<ChatMessage> history) async {
    final body = <String, dynamic>{
      'message': message,
      'history': [
        for (final item in history)
          {'role': item.isUser ? 'user' : 'assistant', 'content': item.text},
      ],
    };
    final reply = await _api.post('/chat', body);
    if (reply is Map && reply['reply'] != null) return reply['reply'].toString();
    return '';
  }
}
