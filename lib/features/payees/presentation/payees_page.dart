import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../domain/payee_notifier.dart';
import '../data/payee_model.dart';
import 'widgets/payee_form_sheet.dart';

class PayeesPage extends ConsumerWidget {
  const PayeesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final payees = ref.watch(payeeStateProvider);
    final aliases = payees.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Odbiorcy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showForm(context, ref),
          ),
        ],
      ),
      body: aliases.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 64, color: colors.textTertiary),
                  const SizedBox(height: 16),
                  Text('Brak odbiorców', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Dodaj pierwszego odbiorcę', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: aliases.length,
              itemBuilder: (context, index) {
                final alias = aliases[index];
                final payee = payees[alias]!;
                return _PayeeTile(
                  payee: payee,
                  colors: colors,
                  onEdit: () => _showForm(context, ref, payee: payee),
                  onDelete: () => _confirmDelete(context, ref, payee, colors),
                );
              },
            ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, {PayeeModel? payee}) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.surface,
      builder: (_) => PayeeFormSheet(existing: payee),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, PayeeModel payee, AppThemeColors colors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: const Text('Usunąć odbiorcę?'),
        content: Text('Czy na pewno usunąć "${payee.alias}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () {
              ref.read(payeeStateProvider.notifier).delete(payee.alias);
              Navigator.pop(ctx);
            },
            child: Text('Usuń', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
  }
}

class _PayeeTile extends StatelessWidget {
  final PayeeModel payee;
  final AppThemeColors colors;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PayeeTile({
    required this.payee,
    required this.colors,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  payee.alias.substring(0, 1),
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(payee.alias, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(payee.odbiorca, style: Theme.of(context).textTheme.bodyMedium),
                  if (payee.kwota.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('${payee.kwota} PLN', style: Theme.of(context).textTheme.labelSmall),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
              color: colors.textSecondary,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
              color: colors.error,
            ),
          ],
        ),
      ),
    );
  }
}
