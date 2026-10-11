// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/foundation.dart' show debugPrint;

/// Triggers the browser's file download for the Excel export (web only).
Future<void> downloadXlsxWeb(List<int> bytes, String filename) async {
  try {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = filename;
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
    debugPrint('Excel export: download triggered for $filename');
  } catch (e) {
    debugPrint('ERROR: Excel export failed: $e');
  }
}
