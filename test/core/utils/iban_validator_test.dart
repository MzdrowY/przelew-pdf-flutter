import 'package:flutter_test/flutter_test.dart';
import 'package:przelew_pdf/core/utils/iban_validator.dart';

void main() {
  group('IbanValidator.validate', () {
    test('accepts 26 digits', () {
      final (valid, cleaned) = IbanValidator.validate('26 1050 1445 1000 0090 3014 4510');
      expect(valid, isTrue);
      expect(cleaned, '26105014451000009030144510');
    });

    test('accepts PL + 26 digits and strips PL', () {
      final (valid, cleaned) = IbanValidator.validate('PL 61 1090 1014 0000 0712 1981 2874');
      expect(valid, isTrue);
      expect(cleaned, '61109010140000071219812874');
    });

    test('rejects too short number', () {
      final (valid, _) = IbanValidator.validate('12 3456 7890');
      expect(valid, isFalse);
    });

    test('rejects letters other than PL prefix', () {
      final (valid, _) = IbanValidator.validate('AB 61 1090 1014 0000 0712 1981 2874');
      expect(valid, isFalse);
    });

    test('rejects empty string', () {
      final (valid, _) = IbanValidator.validate('');
      expect(valid, isFalse);
    });
  });

  group('IbanValidator.checkMod97', () {
    test('rejects wrong length', () {
      expect(IbanValidator.checkMod97('123456'), isFalse);
    });

    test('rejects non-digits', () {
      expect(IbanValidator.checkMod97('ABCDEFGHIJKLMNOPRSTUWXYZ12'), isFalse);
    });

    test('rejects all zeros', () {
      expect(IbanValidator.checkMod97('0' * 26), isFalse);
    });

    test('accepts valid Polish IBAN', () {
      // PL 61 1090 1014 0000 0712 1981 2874
      expect(IbanValidator.checkMod97('61109010140000071219812874'), isTrue);
    });

    test('rejects invalid check digits', () {
      expect(IbanValidator.checkMod97('61109010140000071219812875'), isFalse);
    });
  });

  group('IbanValidator.format', () {
    test('formats 26 digits in groups of 4', () {
      expect(
        IbanValidator.format('26105014451000009030144510'),
        '2610 5014 4510 0000 9030 1445 10',
      );
    });

    test('cleans whitespace before formatting', () {
      expect(
        IbanValidator.format('  26105014451000009030144510  '),
        '2610 5014 4510 0000 9030 1445 10',
      );
    });

    test('returns unchanged if not 26 digits', () {
      expect(IbanValidator.format('12345'), '12345');
    });
  });
}
