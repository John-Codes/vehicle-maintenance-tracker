import 'package:flutter/material.dart';
import 'chat_api.dart';
import 'chat_logic.dart';

/// One row of the history widget: a conversation thread. Tap to reopen,
/// delete icon to remove it.
class ChatTopicRow extends StatelessWidget {
  final ChatLogic logic;
  final ChatTopic topic;
  final VoidCallback onDeleted;
  const ChatTopicRow({super.key, required this.logic, required this.topic,
      required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: const Icon(Icons.chat_bubble_outline),
      title: Text(topic.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(_when(topic.updatedAt),
          style: TextStyle(color: scheme.onSurfaceVariant)),
      trailing: IconButton(
        tooltip: 'Delete conversation',
        icon: const Icon(Icons.delete_outline),
        onPressed: () async {
          await logic.deleteTopic(topic.topicId);
          onDeleted();
        },
      ),
      onTap: () {
        logic.openTopic(topic.topicId);
        Navigator.pop(context);
      },
    );
  }

  String _when(DateTime time) {
    final now = DateTime.now();
    final local = time.toLocal();
    if (local.year == now.year && local.month == now.month && local.day == now.day) {
      return 'Today ${local.hour.toString().padLeft(2, '0')}:'
          '${local.minute.toString().padLeft(2, '0')}';
    }
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}
