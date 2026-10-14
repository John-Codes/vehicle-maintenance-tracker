import 'package:flutter/material.dart';

/// Short-lived dialog that collects brand/model/year and returns them as a
/// (brand, model, year) triple, or null when cancelled. Neutral placeholders
/// only — no hardcoded examples, no developer jargon.
Future<(String, String, String)?> showAiTypeDialog(BuildContext context, {
  String prefillBrand = '',
  String prefillModel = '',
  String prefillYear = '',
}) =>
    showDialog<(String, String, String)>(
      context: context,
      builder: (_) => _AiTypeDialog(
          brand: prefillBrand, model: prefillModel, year: prefillYear),
    );

class _AiTypeDialog extends StatefulWidget {
  final String brand, model, year;
  const _AiTypeDialog({required this.brand, required this.model, required this.year});
  @override
  State<_AiTypeDialog> createState() => _AiTypeDialogState();
}

class _AiTypeDialogState extends State<_AiTypeDialog> {
  late final brand = TextEditingController(text: widget.brand);
  late final model = TextEditingController(text: widget.model);
  late final year = TextEditingController(text: widget.year);

  @override
  void dispose() {
    brand.dispose();
    model.dispose();
    year.dispose();
    super.dispose();
  }

  void _submit() {
    final parsedYear = int.tryParse(year.text.trim());
    if (brand.text.trim().isEmpty ||
        model.text.trim().isEmpty ||
        parsedYear == null || parsedYear < 1900 || parsedYear > 2100) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter the brand, model, and a year (1900-2100).')));
      return;
    }
    Navigator.pop(context, (brand.text.trim(), model.text.trim(), year.text.trim()));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Get basic maintenance information with AI'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: brand, autofocus: widget.brand.isEmpty,
              decoration: const InputDecoration(labelText: 'Brand'),
              onSubmitted: (_) => _submit()),
          const SizedBox(height: 16),
          TextField(controller: model,
              decoration: const InputDecoration(labelText: 'Model'),
              onSubmitted: (_) => _submit()),
          const SizedBox(height: 16),
          TextField(controller: year, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Year'),
              onSubmitted: (_) => _submit()),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton.icon(onPressed: _submit,
              icon: const Icon(Icons.auto_awesome), label: const Text('Get maintenance info')),
        ],
      );
}
