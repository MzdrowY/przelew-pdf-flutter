// Generuje PDF testowy: kwota 5 zl, slownie 5 zl
// dart run tools/test_5zl.dart
import 'dart:io';
import 'package:przelew_pdf/core/utils/pdf_generator.dart';
import 'package:przelew_pdf/core/utils/kwota_slownie.dart';

Future<void> main() async {
  final bytes = await PdfGenerator.generate(
    nazwaOdbiorcy: 'Firma ABC Sp. z o.o.',
    nazwaOdbiorcyCd: 'ul. Kwiatowa 15, 00-001 Warszawa',
    nrRachunkuOdbiorcy: '12345678901234567890123456',
    waluta: 'PLN',
    kwota: '5,00',
    kwotaSlownie: kwotaSlownie('5,00'),
    nazwaZleceniodawcy: 'Jan Kowalski',
    adresZleceniodawcy: 'ul. Sloneczna 42, 00-002 Warszawa',
    kontoZleceniodawcy: '98765432109876543210987654',
    tytulem: 'FV 2026/01/001 za uslugi',
    tytulemCd: 'konsultingowe w styczniu 2026',
    wplataGotowkowa: true,
    odcinek: 'oba',
  );
  final file = File('tools/test_5zl.pdf');
  await file.writeAsBytes(bytes);
  print('OK: ${file.absolute.path} (${bytes.length} B)');
}
