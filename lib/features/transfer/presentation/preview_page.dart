import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../core/utils/kwota_slownie.dart';
import '../domain/transfer_notifier.dart';
import '../../settings/domain/settings_notifier.dart';

class PreviewPage extends ConsumerStatefulWidget {
  const PreviewPage({super.key});

  @override
  ConsumerState<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends ConsumerState<PreviewPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final transferForm = ref.watch(transferFormProvider);
    final settings = ref.watch(settingsStateProvider);

    final kwotaSl = kwotaSlownie(transferForm.kwota.replaceAll(',', '.').trim());

    return Scaffold(
      appBar: AppBar(title: const Text('Podgląd')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dane przelewu', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _PreviewRow(label: 'Odbiorca', value: transferForm.odbiorca),
                _PreviewRow(label: 'Konto', value: transferForm.konto),
                _PreviewRow(label: 'Waluta', value: transferForm.waluta),
                _PreviewRow(label: 'Kwota', value: '${transferForm.kwota} ${transferForm.waluta}'),
                _PreviewRow(label: 'Słownie', value: kwotaSl),
                _PreviewRow(label: 'Tytułem', value: transferForm.tytul1),
                _PreviewRow(label: 'Odcinek', value: _odcinekLabel(transferForm.odcinek)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: _isLoading ? 'Generowanie...' : 'Generuj PDF',
            icon: Icons.picture_as_pdf,
            onPressed: _isLoading
                ? null
                : () => _generatePdf(transferForm, settings, kwotaSl),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Anuluj',
            isOutlined: true,
            icon: Icons.close,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  String _odcinekLabel(String o) {
    switch (o) {
      case 'gorny': return 'Tylko górny';
      case 'dolny': return 'Tylko dolny';
      default: return 'Oba odcinki';
    }
  }

  Future<void> _generatePdf(
    TransferFormState form,
    Map<String, dynamic> settings,
    String kwotaSl,
  ) async {
    setState(() => _isLoading = true);
    HapticFeedback.heavyImpact();

    try {
      final pdfBytes = await PdfGenerator.generate(
        nazwaOdbiorcy: form.odbiorca,
        nazwaOdbiorcyCd: form.odbiorcaCd,
        nrRachunkuOdbiorcy: form.konto.replaceAll(RegExp(r'\s+'), ''),
        waluta: form.waluta.isEmpty ? 'PLN' : form.waluta.toUpperCase(),
        kwota: form.kwota,
        kwotaSlownie: kwotaSl,
        nazwaZleceniodawcy: settings['nazwa'] as String? ?? '',
        adresZleceniodawcy: settings['adres'] as String? ?? '',
        kontoZleceniodawcy: settings['konto_zleceniodawcy'] as String? ?? '',
        tytulem: form.tytul1,
        tytulemCd: form.tytul2,
        wplataGotowkowa: settings['wplata_gotowkowa'] as bool? ?? true,
        odcinek: form.odcinek,
        shiftX: (settings['shift_x'] as num?)?.toDouble() ?? -2.0,
        shiftY: (settings['shift_y'] as num?)?.toDouble() ?? -1.0,
        fontSize: (settings['font_size'] as num?)?.toDouble() ?? 11,
        offsetY: (settings['offset_y'] as num?)?.toDouble() ?? 3.5,
        cellW: (settings['cell_w'] as num?)?.toDouble() ?? 5.0,
      );

      final dir = await getApplicationDocumentsDirectory();
      final now = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
      final file = File('${dir.path}/Polecenie_przelewu_$now.pdf');
      await file.writeAsBytes(pdfBytes);

      final kontoClean = form.konto.replaceAll(RegExp(r'\s+'), '');
      final kontoSuffix = kontoClean.length >= 4
          ? kontoClean.substring(kontoClean.length - 4)
          : kontoClean;

      await ref.read(settingsStateProvider.notifier).addHistoryEntry({
        'data': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        'odbiorca': form.odbiorca,
        'konto': kontoSuffix,
        'kwota': form.kwota,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF zapisany: ${file.path}')),
      );
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'Polecenie_przelewu_$now.pdf',
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final colors = context.appColors;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e'), backgroundColor: colors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            )),
          ),
          Expanded(
            child: Text(value.isEmpty ? '-' : value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
