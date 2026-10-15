import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'chat_api.dart';
import 'chat_message.dart';

/// App-lifetime chat state so the conversation survives tab switches, backed by
/// the server-side per-user history (`/chat/history`).
final chatLogic = ChatLogic();

class ChatLogic extends ChangeNotifier {
  final messages = <ChatMessage>[];
  final textController = TextEditingController();
  final focusNode = FocusNode();
  bool isLoading = false;

  /// Photo chosen for the next message (in-memory only; never stored).
  Uint8List? pendingPhoto;
  final ChatApi _api = ChatApi();
  bool _historyLoaded = false;

  ChatLogic() {
    messages.add(ChatMessage(
      text: 'Ask me anything about your service records...',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  /// Pull the signed-in user's saved thread once the session is known.
  Future<void> loadHistory() async {
    if (_historyLoaded) return;
    _historyLoaded = true;
    try {
      final history = await _api.loadHistory();
      if (history.isNotEmpty) {
        messages
          ..clear()
          ..addAll(history);
        notifyListeners();
      }
    } catch (_) {
      // History is a convenience; chat still works without it.
    }
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
    final text = textController.text.trim();
    if (text.isEmpty && pendingPhoto == null) return;
    if (isLoading) return;
    if (text.isEmpty) textController.text = 'Daily inspection photo';
    final message = textController.text.trim();
    final photo = pendingPhoto;
    textController.clear();
    pendingPhoto = null;
    focusNode.requestFocus();
    messages.add(ChatMessage(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
      isLoading: true,
      image: photo,
    ));
    isLoading = true;
    notifyListeners();

    String reply;
    try {
      reply = await _api.ask(message, List<ChatMessage>.from(messages), photo: photo);
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
