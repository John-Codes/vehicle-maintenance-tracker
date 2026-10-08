import 'package:flutter/material.dart';
import '../core/large_display.dart';
import '../features/auth/auth_gate.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

class TrackerApp extends StatefulWidget {
  const TrackerApp({super.key});
  @override State<TrackerApp> createState() => _TrackerAppState();
}

class _TrackerAppState extends State<TrackerApp> {
  @override void initState() { super.initState(); loadBiggerTextButtonsSetting(); }

  @override Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: themeNotifier,
        builder: (_, mode, child) => MaterialApp(
          title: 'Service Tracker',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff205c4b)),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xff205c4b), brightness: Brightness.dark),
            useMaterial3: true,
          ),
          themeMode: mode,
          builder: (context, child) => ValueListenableBuilder<bool>(
            valueListenable: biggerTextButtonsNotifier,
            builder: (_, bigger, app) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(bigger ? 1.1 : 1.0),
              ),
              child: app!,
            ),
            child: child,
          ),
          home: const AuthGate(),
        ),
      );
}
