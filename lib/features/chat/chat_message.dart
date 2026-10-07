class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });

  ChatMessage copyWith({bool? isLoading}) => ChatMessage(
        text: text,
        isUser: isUser,
        timestamp: timestamp,
        isLoading: isLoading ?? this.isLoading,
      );
}
