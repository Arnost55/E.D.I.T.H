import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/edith_theme.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  late final TextEditingController _nameController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    _nameController = TextEditingController(text: prefs.getString('edith_display_name') ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final prefs = ref.read(sharedPreferencesProvider);
    final name = _nameController.text.trim();
    if (name.isNotEmpty) await prefs.setString('edith_display_name', name);
    await prefs.setBool('edith_setup_complete', true);
    if (!mounted) return;
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EdithColors.bgPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.hub_outlined, size: 56, color: EdithColors.accentStrong),
                  const SizedBox(height: 20),
                  Text('Set up E.D.I.T.H.', textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: EdithColors.textPrimary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('A few details make this dashboard yours. Hardware status will stay unreported until a real integration is connected.',
                    textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: EdithColors.textMuted)),
                  const SizedBox(height: 32),
                  _section('YOUR PROFILE', Icons.person_outline, [
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'What should E.D.I.T.H. call you?', hintText: 'Name (optional)'),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _section('THIS DEVICE', Icons.phone_android, [
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.battery_charging_full, color: EdithColors.accentStrong),
                      title: Text('Phone status'),
                      subtitle: Text('Battery level and charging state are read from this phone.'),
                    ),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.camera_alt_outlined, color: EdithColors.accentStrong),
                      title: Text('Vision camera'),
                      subtitle: Text('Live camera capture is not implemented yet; the Vision preview is simulated.'),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _section('OPTIONAL DEVICES', Icons.bluetooth_searching, [
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.info_outline, color: EdithColors.statusWarning),
                      title: Text('Glasses are not paired'),
                      subtitle: Text('Bluetooth pairing is not available in this build. E.D.I.T.H. will not report a connection until pairing is implemented.'),
                    ),
                  ]),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _saving ? null : _finish,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(_saving ? 'Saving…' : 'Finish setup'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: EdithColors.panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: EdithColors.panelBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, color: EdithColors.accentStrong, size: 19), const SizedBox(width: 8), Text(title, style: const TextStyle(color: EdithColors.accentStrong, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          ...children,
        ]),
      );
}
