// Generuje przykladowy PDF z danymi - do testowania bez wypelniania formularza.
//
// Uzycie: dart run tools/generate_sample_pdf.dart

import 'dart:io';
import 'package:przelew_pdf/core/utils/pdf_generator.dart';
import 'package:przelew_pdf/core/utils/kwota_slownie.dart';

Future<void> main() async {
  final bytes = await PdfGenerator.generate(
    nazwaOdbiorcy: 'Firma ABC Sp. z o.o.',
    nazwaOdbiorcyCd: 'ul. Kwiatowa 15, 00-001 Warszawa',
    nrRachunkuOdbiorcy: '12345678901234567890123456',
    waluta: 'PLN',
    kwota: '1250,50',
    kwotaSlownie: kwotaSlownie('1250,50'),
    nazwaZleceniodawcy: 'Jan Kowalski',
    adresZleceniodawcy: 'ul. Sloneczna 42, 00-002 Warszawa',
    kontoZleceniodawcy: '98765432109876543210987654',
    tytulem: 'FV 2026/01/001 za uslugi',
    tytulemCd: 'konsultingowe w styczniu 2026',
    wplataGotowkowa: false,
    odcinek: 'oba',
  );
  final file = File('tools/sample_transfer.pdf');
  await file.writeAsBytes(bytes);
  print('Wygenerowano: ${file.absolute.path}');
  print('Rozmiar: ${bytes.length} bajtow');
}
