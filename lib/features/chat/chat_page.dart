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
    WidgetsBinding.instance.addPostFrameCallback((_) => logic.loadHistory());
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

  Future<void> _onMenu(String action) async {
    if (action == 'reload') {
      try {
        final count = await logic.reloadHistory();
        _snack(count > 0 ? 'Loaded $count saved messages.' : 'No saved history yet.');
      } catch (error) {
        _snack('Could not load history: $_short(error)');
      }
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear chat history?'),
        content: const Text('Your saved conversation on the server will be '
            'permanently deleted. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await logic.clearHistory();
      _snack('History cleared.');
    } catch (error) {
      _snack('Could not clear history: $_short(error)');
    }
  }

  String _short(Object error) => error.toString().replaceFirst('Exception: ', '');

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final pad = width < 640 ? 16.0 : 28.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Chat history',
            onSelected: _onMenu,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'reload', child: Text('Reload history')),
              PopupMenuItem(value: 'clear', child: Text('Clear history')),
            ],
          ),
        ],
      ),
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
