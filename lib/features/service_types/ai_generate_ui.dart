import 'package:flutter/material.dart';

import '../../core/api_client.dart';

/// "Generate with AI": brand/model/year in, the AI drafts a general
/// maintenance checklist for that exact vehicle via the backend's
/// OpenRouter call. Shows the reference-purposes-only disclaimer.
Future<void> showAiTypeGenerator(BuildContext context, VoidCallback onCreated) async {
  final brand = TextEditingController();
  final model = TextEditingController();
  final year = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _AiTypeDialog(brand: brand, model: model, year: year),
  );
  if (result != null && context.mounted) {
    await showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Checklist created 🎉'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(result),
        const SizedBox(height: 12),
        const Text('Reference purposes only: always confirm against the '
            "manufacturer's manual and your shop's procedures.",
            style: TextStyle(fontStyle: FontStyle.italic)),
      ]),
      actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ));
    onCreated();
  }
  brand.dispose();
  model.dispose();
  year.dispose();
}

class _AiTypeDialog extends StatefulWidget {
  final TextEditingController brand, model, year;
  const _AiTypeDialog({required this.brand, required this.model, required this.year});
  @override
  State<_AiTypeDialog> createState() => _AiTypeDialogState();
}

class _AiTypeDialogState extends State<_AiTypeDialog> {
  var busy = false;

  Future<void> generate() async {
    final parsedYear = int.tryParse(widget.year.text.trim());
    if (widget.brand.text.trim().isEmpty ||
        widget.model.text.trim().isEmpty ||
        parsedYear == null || parsedYear < 1900 || parsedYear > 2100) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter the brand, model, and a valid year.')));
      return;
    }
    setState(() => busy = true);
    try {
      final data = Map<String, dynamic>.from((await ApiClient().post(
          '/service-types/ai-generate',
          {'brand': widget.brand.text.trim(), 'model': widget.model.text.trim(), 'year': parsedYear})) as Map);
      final type = Map<String, dynamic>.from(data['type']);
      if (mounted) Navigator.pop(context, '"${type['name']}" was added to your types.');
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$err')));
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Generate with AI'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: widget.brand, enabled: !busy,
              decoration: const InputDecoration(labelText: 'Brand (e.g. Toyota)')),
          const SizedBox(height: 16),
          TextField(controller: widget.model, enabled: !busy,
              decoration: const InputDecoration(labelText: 'Model (e.g. Prius)')),
          const SizedBox(height: 16),
          TextField(controller: widget.year, enabled: !busy, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Year (e.g. 2012)')),
          if (busy) ...[
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            const Text('AI is getting the general maintenance information — hang tight',
                textAlign: TextAlign.center),
          ],
        ]),
        actions: [
          if (!busy) TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          if (!busy) FilledButton.icon(onPressed: generate,
              icon: const Icon(Icons.auto_awesome), label: const Text('Generate')),
        ],
      );
}
