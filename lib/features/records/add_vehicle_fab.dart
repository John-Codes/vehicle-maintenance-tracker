import 'dart:async';

import 'package:flutter/material.dart';

/// The big add button: cycles "Add car / Add truck / Add heavy equipment"
/// with matching icons and a bright gradient so it's obvious what to tap.
class AddVehicleFab extends StatefulWidget {
  final VoidCallback onPressed;
  const AddVehicleFab({super.key, required this.onPressed});
  @override
  State<AddVehicleFab> createState() => _AddVehicleFabState();
}

class _AddVehicleFabState extends State<AddVehicleFab> {
  static const _items = [
    (Icons.directions_car, 'Add car'),
    (Icons.local_shipping, 'Add truck'),
    (Icons.construction, 'Add heavy equipment'),
  ];
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2500),
        (_) => setState(() => _index = (_index + 1) % _items.length));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xff1fddb9), Color(0xff0b7c66)]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Color(0x400b7c66), blurRadius: 12, offset: Offset(0, 5)),
          ],
        ),
        child: FilledButton.icon(
          onPressed: widget.onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            minimumSize: const Size.fromHeight(56),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(position: Tween<Offset>(
                  begin: const Offset(0, 0.6), end: Offset.zero).animate(animation),
                  child: child)),
            child: Icon(_items[_index].$1, key: ValueKey(_index)),
          ),
          label: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(position: Tween<Offset>(
                  begin: const Offset(0, 0.6), end: Offset.zero).animate(animation),
                  child: child)),
            child: Text(_items[_index].$2,
                key: ValueKey(_index), style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      );
}
