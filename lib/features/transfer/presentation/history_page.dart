import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/domain/settings_notifier.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyListProvider);

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
                return Padding(
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
                      Text('…${e['konto'] ?? ''}', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
