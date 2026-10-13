import 'package:flutter/material.dart';

import '../features/chat/chat_page.dart';
import '../features/profile/settings_page.dart';
import '../features/records/records_page.dart';

/// Bottom-nav shell. Team management lives in Settings.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  var tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const RecordsPage(),
      const ChatPage(),
      const SettingsPage(),
    ];
    return Scaffold(
      body: pages[tab.clamp(0, pages.length - 1)],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.clamp(0, pages.length - 1),
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.build_outlined), label: 'Records'),
          const NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          const NavigationDestination(icon: Icon(Icons.person_outline), label: 'Settings'),
        ],
      ),
    );
  }
}
