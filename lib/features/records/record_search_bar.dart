import 'package:flutter/material.dart';

/// Text field used to filter the service records list.
/// Reports every keystroke to [onChanged]; debouncing is handled by the caller.
class RecordSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const RecordSearchBar({super.key, required this.controller, required this.onChanged});
  @override State<RecordSearchBar> createState() => _RecordSearchBarState();
}

class _RecordSearchBarState extends State<RecordSearchBar> {
  @override void initState() { super.initState(); widget.controller.addListener(_syncClearButton); }
  @override void dispose() { widget.controller.removeListener(_syncClearButton); super.dispose(); }
  void _syncClearButton() => setState(() {});
  void _clear() { widget.controller.clear(); widget.onChanged(''); }

  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
    child: TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: 'Search records (vehicle, VIN, technician, notes...)',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.controller.text.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: _clear),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
    ),
  );
}
