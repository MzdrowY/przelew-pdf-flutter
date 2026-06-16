import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/domain/settings_notifier.dart';

enum AppThemeMode {
  dark('dark', 'Ciemny'),
  office('office', 'Biuro');

  final String key;
  final String label;
  const AppThemeMode(this.key, this.label);

  static AppThemeMode fromKey(String? key) {
    return AppThemeMode.values.firstWhere(
      (e) => e.key == key,
      orElse: () => AppThemeMode.dark,
    );
  }
}

final appThemeModeProvider = Provider<AppThemeMode>((ref) {
  final settings = ref.watch(settingsStateProvider);
  if (settings.isEmpty) return AppThemeMode.dark;
  return AppThemeMode.fromKey(settings['theme_mode'] as String?);
});
