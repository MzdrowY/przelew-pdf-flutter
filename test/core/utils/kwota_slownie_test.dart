import 'package:flutter_test/flutter_test.dart';
import 'package:przelew_pdf/core/utils/kwota_slownie.dart';

void main() {
  group('kwotaSlownie', () {
    test('1 złoty 1 grosz', () {
      expect(kwotaSlownie('1,01'), 'jeden złoty jeden grosz');
    });

    test('2 złote 2 grosze', () {
      expect(kwotaSlownie('2,02'), 'dwa złote dwa grosze');
    });

    test('5 złotych 5 groszy', () {
      expect(kwotaSlownie('5,05'), 'pięć złotych pięć groszy');
    });

    test('12 złotych 34 grosze', () {
      expect(kwotaSlownie('12,34'), 'dwanaście złotych trzydzieści cztery grosze');
    });

    test('100 złotych', () {
      expect(kwotaSlownie('100'), 'sto złotych zero groszy');
    });

    test('1111 złotych 11 groszy', () {
      expect(kwotaSlownie('1111,11'), 'tysiąc sto jedenaście złotych jedenaście groszy');
    });

    test('1000000 złotych', () {
      expect(kwotaSlownie('1000000'), 'milion złotych zero groszy');
    });

    test('2000000 złotych', () {
      expect(kwotaSlownie('2000000'), 'dwa miliony złotych zero groszy');
    });

    test('5000000 złotych', () {
      expect(kwotaSlownie('5000000'), 'pięć milionów złotych zero groszy');
    });

    test('handles dot as decimal separator', () {
      expect(kwotaSlownie('10.50'), 'dziesięć złotych pięćdziesiąt groszy');
    });

    test('pads single digit grosze', () {
      expect(kwotaSlownie('0,5'), 'zero złotych pięćdziesiąt groszy');
    });

    test('rounds grosze to 2 digits', () {
      expect(kwotaSlownie('0,999'), 'zero złotych dziewięćdziesiąt dziewięć groszy');
    });
  });
}
