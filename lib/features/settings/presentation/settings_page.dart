import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../domain/settings_notifier.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _nazwaCtrl = TextEditingController();
  final _adresCtrl = TextEditingController();
  final _kontoCtrl = TextEditingController();
  bool _wplataGotowkowa = true;
  bool _initialized = false;

  @override
  void dispose() {
    _nazwaCtrl.dispose();
    _adresCtrl.dispose();
    _kontoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsStateProvider);

    if (!_initialized) {
      _nazwaCtrl.text = settings['nazwa'] as String? ?? '';
      _adresCtrl.text = settings['adres'] as String? ?? '';
      _kontoCtrl.text = settings['konto_zleceniodawcy'] as String? ?? '';
      _wplataGotowkowa = settings['wplata_gotowkowa'] as bool? ?? true;
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Zleceniodawca', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Wpłata gotówkowa'),
                  subtitle: const Text('Bez konta – kwota słownie'),
                  value: _wplataGotowkowa,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() => _wplataGotowkowa = v),
                ),
                const SizedBox(height: 8),
                CustomTextField(label: 'Nazwa', controller: _nazwaCtrl),
                const SizedBox(height: 12),
                CustomTextField(label: 'Adres', controller: _adresCtrl, maxLines: 2),
                const SizedBox(height: 12),
                CustomTextField(label: 'Nr konta', controller: _kontoCtrl),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Zapisz',
                  icon: Icons.save,
                  onPressed: () {
                    ref.read(settingsStateProvider.notifier).update({
                      'nazwa': _nazwaCtrl.text,
                      'adres': _adresCtrl.text,
                      'konto_zleceniodawcy': _kontoCtrl.text,
                      'wplata_gotowkowa': _wplataGotowkowa,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Zapisano ustawienia')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
