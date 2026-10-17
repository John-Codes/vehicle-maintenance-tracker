import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../auth/auth_controller.dart';
import 'chat_api.dart';
import 'chat_history_mixin.dart';
import 'chat_message.dart';

/// App-lifetime chat state so the conversation survives tab switches, backed by
/// the server-side per-user history (`/chat/history`).
final chatLogic = ChatLogic();

class ChatLogic extends ChangeNotifier with ChatHistoryMixin {
  @override
  final messages = <ChatMessage>[];
  final textController = TextEditingController();
  final focusNode = FocusNode();
  bool isLoading = false;

  /// Photo chosen for the next message (in-memory only; never stored).
  Uint8List? pendingPhoto;
  final ChatApi _api = ChatApi();

  ChatLogic() {
    resetToGreeting();
    AuthController.instance.addListener(onAuthChanged);
  }

  @override
  void resetToGreeting() {
    messages.clear();
    messages.add(ChatMessage(text: 'Ask me anything about your service records...',
        isUser: false, timestamp: DateTime.now()));
  }

  Future<void> attachPhoto() async {
    if (isLoading || pendingPhoto != null) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked == null) return;
    pendingPhoto = await picked.readAsBytes();
    notifyListeners();
  }

  void removePendingPhoto() {
    pendingPhoto = null;
    notifyListeners();
  }

  Future<void> sendMessage() async {
    if (isLoading) return;
    if (textController.text.trim().isEmpty) {
      if (pendingPhoto == null) return;
      textController.text = 'Daily inspection photo';
    }
    final message = textController.text.trim();
    final photo = pendingPhoto;
    textController.clear();
    pendingPhoto = null;
    focusNode.requestFocus();
    messages.add(ChatMessage(text: message, isUser: true,
        timestamp: DateTime.now(), isLoading: true, image: photo));
    isLoading = true;
    notifyListeners();

    String reply;
    try {
      final turn = await _api.ask(message, List<ChatMessage>.from(messages),
          photo: photo, topicId: currentTopicId);
      onTurnFinished(turn.topicId);
      reply = turn.reply;
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
    if (messages.isEmpty || !messages.last.isUser || !messages.last.isLoading) return;
    final last = messages.removeLast();
    messages.add(last.copyWith(isLoading: false));
  }

  @override
  void dispose() {
    AuthController.instance.removeListener(onAuthChanged);
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
