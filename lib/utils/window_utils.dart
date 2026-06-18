import 'package:flutter/services.dart';

class WindowUtils {
  static const _channel = MethodChannel('window_utils');

  static Future<void> setTitleBarDarkMode(bool isDark) async {
    try {
      await _channel.invokeMethod('setTitleBarDarkMode', {'isDark': isDark});
    } catch (e) {
      // Ignore on platforms where the channel is not implemented.
    }
  }
}
