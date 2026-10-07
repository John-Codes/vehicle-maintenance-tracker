import 'package:flutter/material.dart';
import 'chat_api.dart';
import 'chat_message.dart';

/// App-lifetime chat state so the conversation survives tab switches.
final chatLogic = ChatLogic();

class ChatLogic extends ChangeNotifier {
  final messages = <ChatMessage>[];
  final textController = TextEditingController();
  final focusNode = FocusNode();
  bool isLoading = false;
  final ChatApi _api = ChatApi();

  ChatLogic() {
    messages.add(ChatMessage(
      text: 'Ask me anything about your service records...',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty || isLoading) return;
    final history = List<ChatMessage>.from(messages);
    textController.clear();
    focusNode.requestFocus();
    messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      isLoading: true,
    ));
    isLoading = true;
    notifyListeners();

    String reply;
    try {
      reply = await _api.ask(text, history);
      if (reply.isEmpty) reply = 'The assistant returned an empty reply.';
    } catch (error) {
      reply = 'Error: ${error.toString().replaceFirst('Exception: ', '')}';
    }

    _resolveUserMessage();
    messages.add(ChatMessage(text: reply, isUser: false, timestamp: DateTime.now()));
    isLoading = false;
    notifyListeners();
  }

  void _resolveUserMessage() {
    if (messages.isNotEmpty && messages.last.isUser && messages.last.isLoading) {
      final last = messages.removeLast();
      messages.add(last.copyWith(isLoading: false));
    }
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
