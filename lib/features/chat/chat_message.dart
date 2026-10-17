import 'package:flutter/foundation.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  /// Photo attached to this user message (in-memory preview only).
  final Uint8List? image;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
    this.image,
  });

  ChatMessage copyWith({bool? isLoading}) => ChatMessage(
        text: text,
        isUser: isUser,
        timestamp: timestamp,
        isLoading: isLoading ?? this.isLoading,
        image: image,
      );

  factory ChatMessage.fromHistory(Map<String, dynamic> item) => ChatMessage(
        text: (item['content'] ?? '').toString(),
        isUser: item['role'] == 'user',
        timestamp: DateTime.tryParse((item['created_at'] ?? '').toString()) ??
            DateTime.now(),
      );
}
