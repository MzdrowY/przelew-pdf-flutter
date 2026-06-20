import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class SettingsRepository {
  SharedPreferences? _prefs;

  Future<void> _ensure() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<Map<String, dynamic>> load() async {
    await _ensure();
    return {
      'nazwa': _prefs!.getString('nazwa') ?? '',
      'adres': _prefs!.getString('adres') ?? '',
      'konto_zleceniodawcy': _prefs!.getString('konto_zleceniodawcy') ?? '',
      'wplata_gotowkowa': _prefs!.getBool('wplata_gotowkowa') ?? true,
      'theme_mode': _prefs!.getString('theme_mode') ?? 'dark',
      'shift_x': _prefs!.getDouble('shift_x') ?? AppConstants.defaultShiftX,
      'shift_y': _prefs!.getDouble('shift_y') ?? AppConstants.defaultShiftY,
      'font_size': _prefs!.getDouble('font_size') ?? AppConstants.defaultFontSize,
      'offset_y': _prefs!.getDouble('offset_y') ?? AppConstants.defaultOffsetY,
      'cell_w': _prefs!.getDouble('cell_w') ?? AppConstants.defaultCellW,
    };
  }

  Future<void> save(Map<String, dynamic> settings) async {
    await _ensure();
    await _prefs!.setString('nazwa', settings['nazwa'] as String? ?? '');
    await _prefs!.setString('adres', settings['adres'] as String? ?? '');
    await _prefs!.setString('konto_zleceniodawcy', settings['konto_zleceniodawcy'] as String? ?? '');
    await _prefs!.setBool('wplata_gotowkowa', settings['wplata_gotowkowa'] as bool? ?? true);
    await _prefs!.setString('theme_mode', settings['theme_mode'] as String? ?? 'dark');
    await _prefs!.setDouble('shift_x', (settings['shift_x'] as num?)?.toDouble() ?? AppConstants.defaultShiftX);
    await _prefs!.setDouble('shift_y', (settings['shift_y'] as num?)?.toDouble() ?? AppConstants.defaultShiftY);
    await _prefs!.setDouble('font_size', (settings['font_size'] as num?)?.toDouble() ?? AppConstants.defaultFontSize);
    await _prefs!.setDouble('offset_y', (settings['offset_y'] as num?)?.toDouble() ?? AppConstants.defaultOffsetY);
    await _prefs!.setDouble('cell_w', (settings['cell_w'] as num?)?.toDouble() ?? AppConstants.defaultCellW);
  }

  Future<void> addHistoryEntry(Map<String, String> entry) async {
    await _ensure();
    final history = _prefs!.getStringList('historia') ?? [];
    history.insert(0, jsonEncode(entry));
    if (history.length > AppConstants.maxHistory) {
      history.removeRange(AppConstants.maxHistory, history.length);
    }
    await _prefs!.setStringList('historia', history);
  }

  Future<void> clearAll() async {
    await _ensure();
    await _prefs!.clear();
  }

  List<Map<String, String>> getHistory() {
    final history = _prefs?.getStringList('historia') ?? [];
    return history.map((e) {
      try {
        final decoded = jsonDecode(e) as Map<String, dynamic>;
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      } catch (_) {
        // Backwards compatibility: old format used '|' as delimiter.
        final parts = e.split('|');
        return {
          'data': parts.isNotEmpty ? parts[0] : '',
          'odbiorca': parts.length > 1 ? parts[1] : '',
          'konto': parts.length > 2 ? parts[2] : '',
          'kwota': parts.length > 3 ? parts[3] : '',
        };
      }
    }).toList();
  }
}
