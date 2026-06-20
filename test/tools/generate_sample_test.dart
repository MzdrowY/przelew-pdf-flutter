// Generuje przykladowy PDF do podgladu (umozliwia weryfikacje mapowania blankietu).
//
// Uruchom: flutter test test/tools/generate_sample_test.dart

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:przelew_pdf/core/utils/pdf_generator.dart';
import 'package:przelew_pdf/core/utils/kwota_slownie.dart';
import 'package:przelew_pdf/core/utils/iban_validator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('generuje przykladowy PDF z danymi', () async {
    // Prawidlowe IBAN-y (przechodza walidacje mod 97)
    final kontoOdbiorcy = '04123456789012345678901234';
    final kontoZleceniodawcy = '71987654321098765432109876';
    expect(IbanValidator.checkMod97(kontoOdbiorcy), isTrue,
        reason: 'IBAN odbiorcy musi byc prawidlowy');
    expect(IbanValidator.checkMod97(kontoZleceniodawcy), isTrue,
        reason: 'IBAN zleceniodawcy musi byc prawidlowy');
    final bytes = await PdfGenerator.generate(
      nazwaOdbiorcy: 'Firma ABC Sp. z o.o.',
      nazwaOdbiorcyCd: 'ul. Kwiatowa 15, 00-001 Warszawa',
      nrRachunkuOdbiorcy: kontoOdbiorcy,
      waluta: 'PLN',
      kwota: '1250,50',
      kwotaSlownie: kwotaSlownie('1250,50'),
      nazwaZleceniodawcy: 'Jan Kowalski',
      adresZleceniodawcy: 'ul. Sloneczna 42, 00-002 Warszawa',
      kontoZleceniodawcy: kontoZleceniodawcy,
      tytulem: 'FV 2026/01/001 za uslugi',
      tytulemCd: 'konsultingowe w styczniu 2026',
      wplataGotowkowa: false,
      odcinek: 'oba',
    );
    final file = File('tools/sample_transfer.pdf');
    await file.writeAsBytes(bytes);
    print('Wygenerowano: ${file.absolute.path}');
    print('Rozmiar: ${bytes.length} bajtow');
  });
}
