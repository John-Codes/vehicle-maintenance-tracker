import 'package:flutter/material.dart';
import '../../app/app.dart';
import '../../core/cold_start_notice.dart';
import '../../core/large_display.dart';
import '../auth/session_section.dart';
import 'profile_repository.dart';
import 'technician.dart';
import '../service_types/service_types_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final repo = ProfileRepository();
  final name = TextEditingController(), phone = TextEditingController(), email = TextEditingController();
  var loading = true;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try { final p = await repo.load(); name.text = p.name; phone.text = p.phone; email.text = p.email; } finally { if (mounted) setState(() => loading = false); }
  }
  Future<void> _save() async {
    await repo.save(Technician(name: name.text.trim(), phone: phone.text.trim(), email: email.text.trim()));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved')));
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Technician settings')),
    body: loading ? const ColdStartNotice() : ListView(padding: const EdgeInsets.all(20), children: [
      const SessionSection(),
      TextField(controller: name, decoration: const InputDecoration(labelText: 'Technician name')),
      TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number')),
      TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
      const SizedBox(height: 24),
      ValueListenableBuilder(
        valueListenable: themeNotifier,
        builder: (_, mode, child) => SwitchListTile(
          title: const Text('Dark mode'),
          value: mode == ThemeMode.dark,
          onChanged: (_) => themeNotifier.value = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
        ),
      ),
      const SizedBox(height: 12),
      ValueListenableBuilder<bool>(
        valueListenable: biggerTextButtonsNotifier,
        builder: (_, bigger, child) => SwitchListTile(
          title: const Text('Bigger text & buttons'),
          subtitle: const Text('Easier reading and tapping'),
          value: bigger,
          onChanged: (value) => saveBiggerTextButtonsSetting(value),
        ),
      ),
      const SizedBox(height: 24),
      OutlinedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceTypesPage())),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
        icon: const Icon(Icons.category_outlined),
        label: const Text('Manage service types'),
      ),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: _save,
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
        child: const Text('Save settings'),
      ),
      const SizedBox(height: 24),
    ]),
  );
}
