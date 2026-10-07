import 'package:flutter/material.dart';
import 'chat_input_bar.dart';
import 'chat_logic.dart';
import 'chat_message_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final logic = chatLogic;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    logic.addListener(_onUpdate);
  }

  @override
  void dispose() {
    logic.removeListener(_onUpdate);
    scrollController.dispose();
    super.dispose();
  }

  void _onUpdate() {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final pad = width < 640 ? 16.0 : 28.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(pad, 18, pad, 28),
            itemCount: logic.messages.length,
            itemBuilder: (_, i) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: ChatMessageBubble(message: logic.messages[i]),
              ),
            ),
          ),
        ),
        ChatInputBar(logic: logic),
      ]),
    );
  }
}