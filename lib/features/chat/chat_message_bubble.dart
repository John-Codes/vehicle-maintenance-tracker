import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'chat_markdown_styles.dart';
import 'chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatMessageBubble({super.key, required this.message});

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Copied!'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (message.isUser) return _UserBubble(text: message.text);
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MarkdownBody(
            data: message.text,
            selectable: true,
            styleSheet: chatMarkdownStyle(context),
          ),
          Row(
            children: [
              IconButton(
                tooltip: 'Copy',
                icon: const Icon(Icons.copy_all_outlined, size: 18),
                onPressed: () => _copy(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 22, left: 42),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
      );
}