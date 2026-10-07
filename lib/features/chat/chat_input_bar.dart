import 'package:flutter/material.dart';
import '../../core/large_display.dart';
import 'chat_enter_to_send.dart';
import 'chat_logic.dart';
import 'chat_send_button.dart';

class ChatInputBar extends StatelessWidget {
  final ChatLogic logic;
  const ChatInputBar({super.key, required this.logic});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sidePadding = MediaQuery.of(context).size.width > 800 ? 24.0 : 16.0;
    return Column(children: [
      if (logic.isLoading) const ChatLoadingLine(),
      Container(
        padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Row(children: [
          Expanded(
            child: EnterToSend(
              isLoading: logic.isLoading,
              onSend: logic.sendMessage,
              child: TextField(
                controller: logic.textController,
                focusNode: logic.focusNode,
                maxLines: null,
                minLines: 1,
                style: TextStyle(color: scheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Ask about your service records...',
                  hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: biggerTextButtonsEnabled ? 16 : 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ChatSendButton(logic: logic),
        ]),
      ),
    ]);
  }
}

class ChatLoadingLine extends StatelessWidget {
  const ChatLoadingLine({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 3,
        child: LinearProgressIndicator(
          minHeight: 3,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
        ),
      );
}