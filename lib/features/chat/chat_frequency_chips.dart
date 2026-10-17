import 'package:flutter/material.dart';
import 'chat_logic.dart';

/// Frequency picker shown while a photo is attached: tells the server which
/// due window the photo must satisfy (daily = today, weekly = this week,
/// monthly = this month).
class ChatFrequencyChips extends StatelessWidget {
  final ChatLogic logic;
  const ChatFrequencyChips({super.key, required this.logic});

  static const _options = {'daily': 'Daily', 'weekly': 'Weekly', 'monthly': 'Monthly'};

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Row(children: [
        const Icon(Icons.event_repeat, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(spacing: 6, children: [
            for (final entry in _options.entries)
              ChoiceChip(
                label: Text(entry.value),
                selected: logic.photoFrequency == entry.key,
                onSelected: (_) => logic.setPhotoFrequency(entry.key),
                labelStyle: TextStyle(
                    color: logic.photoFrequency == entry.key
                        ? scheme.onPrimary
                        : scheme.onSurface),
                selectedColor: scheme.primary,
                showCheckmark: false,
              ),
          ]),
        ),
      ]),
    );
  }
}
