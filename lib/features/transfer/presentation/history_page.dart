import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../settings/domain/settings_notifier.dart';
import '../domain/transfer_notifier.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyListProvider);

    void loadEntry(Map<String, String> e) {
      ref.read(transferFormProvider.notifier).loadFromHistory(
        odbiorca: e['odbiorca'] ?? '',
        odbiorcaCd: e['odbiorcaCd'] ?? '',
        konto: e['konto'] ?? '',
        waluta: e['waluta'] ?? 'PLN',
        kwota: e['kwota'] ?? '',
        tytul1: e['tytul1'] ?? '',
        tytul2: e['tytul2'] ?? '',
        odcinek: e['odcinek'] ?? 'oba',
      );
      context.pushReplacement('/preview');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historia przelewów'),
        toolbarHeight: 44,
      ),
      body: history.isEmpty
          ? Center(
              child: Text('Brak historii', style: Theme.of(context).textTheme.bodyMedium),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: history.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final e = history[i];
                return InkWell(
                  onTap: () => loadEntry(e),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e['odbiorca'] ?? '', style: Theme.of(context).textTheme.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(e['data'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        Text(e['kwota'] ?? '', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(width: 8),
                        Text('…${e['konto_suffix'] ?? (e['konto'] != null && e['konto']!.length >= 4 ? e['konto']!.substring(e['konto']!.length - 4) : (e['konto'] ?? ''))}', style: Theme.of(context).textTheme.bodyMedium),

                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
