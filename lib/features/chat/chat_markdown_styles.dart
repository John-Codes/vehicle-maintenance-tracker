import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Markdown colors follow the tracker theme (dark mode + bigger text apply).
MarkdownStyleSheet chatMarkdownStyle(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  final base = TextStyle(color: scheme.onSurface, fontSize: 16, height: 1.62);
  return MarkdownStyleSheet(
    p: base,
    strong: base.copyWith(fontWeight: FontWeight.bold),
    em: base.copyWith(fontStyle: FontStyle.italic),
    code: base.copyWith(color: scheme.primary, fontSize: 14, fontFamily: 'monospace'),
    h1: base.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
    h2: base.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
    h3: base.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
    blockquote: base.copyWith(fontStyle: FontStyle.italic, color: scheme.onSurfaceVariant),
    a: base.copyWith(color: scheme.primary, decoration: TextDecoration.underline),
  );
}
