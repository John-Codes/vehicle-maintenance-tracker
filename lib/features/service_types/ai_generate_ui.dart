import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import 'ai_status.dart';
import 'ai_type_dialog.dart';

var _generating = false;

/// Non-blocking AI generation: a short dialog collects the vehicle info and
/// closes immediately; generation runs under the hood with the subtle
/// "AI is working" pill showing app-wide. A toast announces success (with
/// the reference-purposes-only disclaimer) or failure.
Future<void> startAiTypeGeneration(BuildContext context, {
  String prefillBrand = '',
  String prefillModel = '',
  String prefillYear = '',
  VoidCallback? onDone,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  if (_generating) {
    messenger.showSnackBar(const SnackBar(
        content: Text('Already generating a checklist — hang tight, you can keep working.')));
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
          content: Text('"${type['name']}" was added to your types ✓ '
              'Reference purposes only — confirm against the manual.')));
      onDone?.call();
    } catch (err) {
      messenger.showSnackBar(SnackBar(content: Text('AI generation failed: $err')));
    } finally {
      aiStatusNotifier.value = null;
      _generating = false;
    }
  }();
}
