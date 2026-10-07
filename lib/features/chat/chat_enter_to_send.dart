import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps the text field so Enter sends the message and Shift+Enter makes a
/// newline, matching common chat app behaviour.
class EnterToSend extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSend;
  final Widget child;

  const EnterToSend({
    super.key,
    required this.isLoading,
    required this.onSend,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Focus(
        onKeyEvent: (_, event) {
          final shouldSend = !isLoading &&
              (event is KeyDownEvent || event is KeyRepeatEvent) &&
              event.logicalKey == LogicalKeyboardKey.enter &&
              !HardwareKeyboard.instance.isShiftPressed;
          if (shouldSend) {
            onSend();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: child,
      );
}