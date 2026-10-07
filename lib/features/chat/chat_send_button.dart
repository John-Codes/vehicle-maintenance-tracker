import 'package:flutter/material.dart';
import '../../core/large_display.dart';
import 'chat_logic.dart';

class ChatSendButton extends StatefulWidget {
  final ChatLogic logic;
  const ChatSendButton({super.key, required this.logic});

  @override
  State<ChatSendButton> createState() => _ChatSendButtonState();
}

class _ChatSendButtonState extends State<ChatSendButton> {
  @override
  void initState() {
    super.initState();
    widget.logic.textController.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.logic.textController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final busy = widget.logic.isLoading;
    final canSend = !busy && widget.logic.textController.text.trim().isNotEmpty;
    final padding = biggerTextButtonsEnabled ? const EdgeInsets.all(15) : const EdgeInsets.all(12);
    return Container(
      decoration: BoxDecoration(
        color: canSend ? scheme.primary : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
      ),
      child: IconButton(
        icon: const Icon(Icons.send, color: Colors.white, size: 22),
        onPressed: canSend ? widget.logic.sendMessage : null,
        tooltip: 'Send message',
        style: IconButton.styleFrom(
          padding: padding,
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}