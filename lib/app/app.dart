import 'package:flutter/material.dart';
import '../core/large_display.dart';
import '../features/profile/settings_page.dart';
import '../features/records/records_page.dart';

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
          home: const _Home(),
        ),
      );
}

class _Home extends StatefulWidget {
  const _Home();
  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  var tab = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: tab == 0 ? const RecordsPage() : const SettingsPage(),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (value) => setState(() => tab = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.build_outlined), label: 'Records'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Settings'),
          ],
        ),
      );
}
