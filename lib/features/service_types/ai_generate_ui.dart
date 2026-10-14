import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import 'ai_status.dart';
import 'ai_type_dialog.dart';

var _generating = false;

/// Non-blocking AI lookup: a short dialog collects the vehicle info and
/// closes immediately; the lookup runs under the hood with the subtle
/// "AI is working" pill showing app-wide. A toast announces the ready
/// checklist (with the reference-purposes-only disclaimer) or a failure.
Future<void> startAiTypeGeneration(BuildContext context, {
  String prefillBrand = '',
  String prefillModel = '',
  String prefillYear = '',
  VoidCallback? onDone,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  if (_generating) {
    messenger.showSnackBar(const SnackBar(
        content: Text('Already getting maintenance info — hang tight, you can keep working.')));
    return;
  }
  final info = await showAiTypeDialog(context,
      prefillBrand: prefillBrand, prefillModel: prefillModel, prefillYear: prefillYear);
  if (info == null) return;
  final (brand, model, year) = info;
  _generating = true;
  aiStatusNotifier.value = AiJob('$year $brand $model');
  () async {
    try {
      final data = Map<String, dynamic>.from((await ApiClient().postOnce(
          '/service-types/ai-generate',
          {'brand': brand, 'model': model, 'year': int.parse(year)})) as Map);
      final type = Map<String, dynamic>.from(data['type']);
      messenger.showSnackBar(SnackBar(
          content: Text('"${type['name']}" basic maintenance checklist is ready ✓ '
              'Find it under "Choose vehicle/equipment type". '
              'Reference purposes only — confirm against the manual.')));
      onDone?.call();
    } catch (err) {
      messenger.showSnackBar(SnackBar(content: Text('Could not get maintenance info: $err')));
    } finally {
      aiStatusNotifier.value = null;
      _generating = false;
    }
  }();
}
