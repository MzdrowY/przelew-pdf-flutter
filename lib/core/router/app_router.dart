import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/payees/presentation/payees_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/transfer/presentation/preview_page.dart';
import '../../features/transfer/presentation/transfer_form_page.dart';
import '../../features/transfer/presentation/history_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'transfer',
        builder: (context, state) => const TransferFormPage(),
      ),
      GoRoute(
        path: '/payees',
        name: 'payees',
        builder: (context, state) => const PayeesPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/preview',
        name: 'preview',
        builder: (context, state) => const PreviewPage(),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryPage(),
      ),
    ],
  );
});
