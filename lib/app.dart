import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_mode.dart';
import 'core/router/app_router.dart';
import 'utils/window_utils.dart';

class PrzelewPdfApp extends ConsumerStatefulWidget {
  const PrzelewPdfApp({super.key});

  @override
  ConsumerState<PrzelewPdfApp> createState() => _PrzelewPdfAppState();
}

class _PrzelewPdfAppState extends ConsumerState<PrzelewPdfApp> {
  ProviderSubscription<AppThemeMode>? _themeSubscription;

  @override
  void initState() {
    super.initState();
    _themeSubscription = ref.listenManual<AppThemeMode>(
      appThemeModeProvider,
      (previous, next) => WindowUtils.setTitleBarDarkMode(next == AppThemeMode.dark),
    );
    _updateTitleBar();
  }

  @override
  void dispose() {
    _themeSubscription?.close();
    super.dispose();
  }

  void _updateTitleBar() {
    final themeMode = ref.read(appThemeModeProvider);
    WindowUtils.setTitleBarDarkMode(themeMode == AppThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      title: 'Polecenie Przelewu PDF',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.forMode(themeMode),
      routerConfig: router,
    );
  }
}
