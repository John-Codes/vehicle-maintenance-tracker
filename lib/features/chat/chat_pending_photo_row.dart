import 'package:flutter/material.dart';
import 'chat_logic.dart';

/// Preview strip above the input once a photo is attached for the next
/// message (in-memory only - photos are never stored).
class ChatPendingPhotoRow extends StatelessWidget {
  final ChatLogic logic;
  const ChatPendingPhotoRow({super.key, required this.logic});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(logic.pendingPhoto!,
                width: 64, height: 64, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Photo attached - it will be sent with your next '
                'message and verified as taken ${_window(logic.photoFrequency)}.'),
          ),
          IconButton(
            tooltip: 'Remove photo',
            icon: const Icon(Icons.close),
            onPressed: logic.removePendingPhoto,
          ),
        ]),
      );

  String _window(String frequency) => switch (frequency) {
        'weekly' => 'within this week',
        'monthly' => 'within this month',
        _ => 'today',
      };
}
