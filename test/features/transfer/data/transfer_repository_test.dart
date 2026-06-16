import 'package:flutter_test/flutter_test.dart';
import 'package:przelew_pdf/features/transfer/data/transfer_repository.dart';

void main() {
  final repo = TransferRepository();

  group('TransferRepository.validateKwota', () {
    test('accepts positive amount with comma', () {
      final (valid, formatted) = repo.validateKwota('123,45');
      expect(valid, isTrue);
      expect(formatted, '123,45');
    });

    test('accepts positive amount with dot', () {
      final (valid, formatted) = repo.validateKwota('123.45');
      expect(valid, isTrue);
      expect(formatted, '123,45');
    });

    test('rejects zero', () {
      final (valid, _) = repo.validateKwota('0');
      expect(valid, isFalse);
    });

    test('rejects negative amount', () {
      final (valid, _) = repo.validateKwota('-10');
      expect(valid, isFalse);
    });

    test('rejects empty string', () {
      final (valid, _) = repo.validateKwota('');
      expect(valid, isFalse);
    });

    test('rejects letters', () {
      final (valid, _) = repo.validateKwota('abc');
      expect(valid, isFalse);
    });
  });

  group('TransferRepository.buildTransferData', () {
    test('builds transfer with default PLN currency', () {
      final data = repo.buildTransferData(
        odbiorca: 'Firma ABC',
        odbiorcaCd: 'ul. Testowa 1',
        konto: 'PL 61 1090 1014 0000 0712 1981 2874',
        waluta: '',
        kwota: '100,50',
        tytul1: 'Faktura 1',
        tytul2: '',
      );

      expect(data.nazwaOdbiorcy, 'Firma ABC');
      expect(data.nazwaOdbiorcyCd, 'ul. Testowa 1');
      expect(data.nrRachunkuOdbiorcy, 'PL61109010140000071219812874');
      expect(data.waluta, 'PLN');
      expect(data.kwota, '100,50');
      expect(data.kwotaSlownie, 'sto złotych pięćdziesiąt groszy');
      expect(data.tytulem, 'Faktura 1');
      expect(data.tytulemCd, '');
    });

    test('uppercases custom currency', () {
      final data = repo.buildTransferData(
        odbiorca: 'X',
        odbiorcaCd: '',
        konto: '0' * 26,
        waluta: 'eur',
        kwota: '1,00',
        tytul1: 'Test',
        tytul2: '',
      );

      expect(data.waluta, 'EUR');
    });
  });
}
