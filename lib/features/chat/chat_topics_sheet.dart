import 'package:flutter/material.dart';
import 'chat_api.dart';
import 'chat_logic.dart';
import 'chat_topic_row.dart';

/// The conversation-history widget: the user's private threads, newest
/// activity first. Tap to reopen a thread, delete icon to remove one.
class ChatTopicsSheet extends StatefulWidget {
  final ChatLogic logic;
  const ChatTopicsSheet({super.key, required this.logic});

  @override
  State<ChatTopicsSheet> createState() => _ChatTopicsSheetState();

  static Future<void> show(BuildContext context, ChatLogic logic) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: ChatTopicsSheet(logic: logic),
        ),
      );
}

class _ChatTopicsSheetState extends State<ChatTopicsSheet> {
  bool _loading = true;
  String? _error;
  var _topics = const <ChatTopic>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final topics = await widget.logic.loadTopicList();
      if (mounted) setState(() { _loading = false; _topics = topics; });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(children: [
            const Icon(Icons.history, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Your conversations',
                style: Theme.of(context).textTheme.titleMedium)),
            IconButton(
              tooltip: 'New conversation',
              icon: const Icon(Icons.add_comment_outlined),
              onPressed: () { widget.logic.newConversation(); Navigator.pop(context); },
            ),
          ]),
        ),
        const Divider(height: 1),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _Hint(text: 'Could not load history: $_error', onRetry: _load)
                  : _topics.isEmpty
                      ? const _Hint(text: 'No saved conversations yet. '
                          'Chats you start are kept here, private to you.')
                      : ListView.builder(
                          itemCount: _topics.length,
                          itemBuilder: (_, i) => ChatTopicRow(
                            logic: widget.logic,
                            topic: _topics[i],
                            onDeleted: _load,
                          ),
                        ),
        ),
      ]);
}

class _Hint extends StatelessWidget {
  final String text;
  final VoidCallback? onRetry;
  const _Hint({required this.text, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(text, textAlign: TextAlign.center)),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ));
}
