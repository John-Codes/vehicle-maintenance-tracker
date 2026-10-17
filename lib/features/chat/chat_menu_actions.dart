import 'package:flutter/material.dart';
import 'chat_logic.dart';
import 'chat_topics_sheet.dart';

/// The chat app-bar menu actions: new conversation, the history widget,
/// and clearing all history (with a confirm dialog).
Future<void> onChatMenuSelected(BuildContext context, ChatLogic logic,
    String action) async {
  switch (action) {
    case 'new':
      logic.newConversation();
      return;
    case 'topics':
      await ChatTopicsSheet.show(context, logic);
      return;
    case 'clear':
      await _clearAll(context, logic);
      return;
  }
}

Future<void> _clearAll(BuildContext context, ChatLogic logic) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Clear all chat history?'),
      content: const Text('Every saved conversation on the server will be '
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
    if (!context.mounted) return;
    _snack(context, 'History cleared.');
  } catch (error) {
    if (!context.mounted) return;
    _snack(context, 'Could not clear history: ${_short(error)}');
  }
}

String _short(Object error) => error.toString().replaceFirst('Exception: ', '');

void _snack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(text),
    duration: const Duration(seconds: 2),
  ));
}
