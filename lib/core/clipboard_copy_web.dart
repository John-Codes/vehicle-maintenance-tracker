import 'dart:html' as html;

import 'package:flutter/services.dart';

/// Web: try the async Clipboard API first (secure contexts), then fall
/// back to the hidden-textarea + execCommand trick, which still works on
/// plain http:// inside a user gesture (Chrome, Firefox, iOS Safari).
Future<bool> copyText(String text) async {
  try {
    await Clipboard.setData(ClipboardData(text: text));
    return true;
  } catch (_) {
    return _execCommandCopy(text);
  }
}

bool _execCommandCopy(String text) {
  final textarea = html.TextAreaElement()
    ..value = text
    ..style.position = 'fixed'
    ..style.opacity = '0';
  html.document.body?.append(textarea);
  textarea.select();
  final copied = html.document.execCommand('copy');
  textarea.remove();
  return copied;
}
