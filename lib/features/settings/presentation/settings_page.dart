import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/theme/app_theme_mode.dart';
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

  @override
  void dispose() {
    _nazwaCtrl.dispose();
    _adresCtrl.dispose();
    _kontoCtrl.dispose();
    super.dispose();
  }

  void _syncFromSettings(Map<String, dynamic> settings) {
    final nazwa = settings['nazwa'] as String? ?? '';
    final adres = settings['adres'] as String? ?? '';
    final konto = settings['konto_zleceniodawcy'] as String? ?? '';
    final wplata = settings['wplata_gotowkowa'] as bool? ?? true;
    if (_nazwaCtrl.text != nazwa) _nazwaCtrl.text = nazwa;
    if (_adresCtrl.text != adres) _adresCtrl.text = adres;
    if (_kontoCtrl.text != konto) _kontoCtrl.text = konto;
    if (_wplataGotowkowa != wplata) _wplataGotowkowa = wplata;
  }

  Future<void> _resetAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset danych'),
        content: const Text('Usunąć wszystkie zapisane dane (ustawienia, historię przelewów)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Anuluj')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Usuń')),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(settingsStateProvider.notifier).clearAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wszystkie dane usunięte')),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final settings = ref.watch(settingsStateProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    _syncFromSettings(settings);

    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wygląd', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                DropdownButtonFormField<AppThemeMode>(
                  key: ValueKey(themeMode),
                  initialValue: themeMode,
                  decoration: InputDecoration(
                    labelText: 'Motyw',
                    filled: true,
                    fillColor: colors.field,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: AppThemeMode.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode.label),
                    );
                  }).toList(),
                  onChanged: (mode) {
                    if (mode == null) return;
                    ref.read(settingsStateProvider.notifier).update({'theme_mode': mode.key});
                  },
                ),
                const SizedBox(height: 24),
                Text('Zleceniodawca', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Wpłata gotówkowa'),
                  subtitle: const Text('Bez konta – kwota słownie'),
                  value: _wplataGotowkowa,
                  activeTrackColor: colors.primary,
                  onChanged: (v) => setState(() => _wplataGotowkowa = v),
                ),
                const SizedBox(height: 8),
                CustomTextField(label: 'Nazwa', controller: _nazwaCtrl),
                const SizedBox(height: 12),
                CustomTextField(label: 'Adres', controller: _adresCtrl, maxLines: 2),
                const SizedBox(height: 12),
                CustomTextField(label: 'Nr konta', controller: _kontoCtrl),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: AppButton(
                    label: 'Zapisz',
                    icon: Icons.save,
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await ref.read(settingsStateProvider.notifier).update({
                        'nazwa': _nazwaCtrl.text,
                        'adres': _adresCtrl.text,
                        'konto_zleceniodawcy': _kontoCtrl.text,
                        'wplata_gotowkowa': _wplataGotowkowa,
                      });
                      if (mounted) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Zapisano ustawienia')),
                        );
                      }
                    },
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: AppButton(
                    label: 'Reset danych',
                    icon: Icons.delete_forever_outlined,
                    isOutlined: true,
                    onPressed: _resetAllData,
                  )),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('O programie', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _aboutRow('Nazwa', 'PrzelewPDF'),
                _aboutRow('Wersja', '2.0.0'),
                _aboutRow('Autor', 'MzdrowY'),
                _aboutRow('Email', 'mzdrowy@gmail.com', isEmail: true),
                const SizedBox(height: 8),
                Text(
                  'Kliknij email aby wysłać wiadomość.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutRow(String label, String value, {bool isEmail = false}) {
    final text = Text(value, style: TextStyle(
      fontSize: 13,
      color: isEmail ? Theme.of(context).colorScheme.primary : null,
      decoration: isEmail ? TextDecoration.underline : null,
    ));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            )),
          ),
          Expanded(child: isEmail
            ? GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: 'mailto:$value'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email skopiowany do schowka'), duration: Duration(seconds: 2)),
                  );
                },
                child: text,
              )
            : text),
        ],
      ),
    );
  }
}
