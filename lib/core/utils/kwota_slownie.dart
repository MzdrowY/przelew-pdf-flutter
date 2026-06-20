const _jedn = ['', 'jeden', 'dwa', 'trzy', 'cztery', 'pięć', 'sześć', 'siedem', 'osiem', 'dziewięć'];
const _naSt = ['', 'jedenaście', 'dwanaście', 'trzynaście', 'czternaście', 'piętnaście', 'szesnaście', 'siedemnaście', 'osiemnaście', 'dziewiętnaście'];
const _dzies = ['', 'dziesięć', 'dwadzieścia', 'trzydzieści', 'czterdzieści', 'pięćdziesiąt', 'sześćdziesiąt', 'siedemdziesiąt', 'osiemdziesiąt', 'dziewięćdziesiąt'];
const _set = ['', 'sto', 'dwieście', 'trzysta', 'czterysta', 'pięćset', 'sześćset', 'siedemset', 'osiemset', 'dziewięćset'];

String _slowa(int n) {
  if (n == 0) return '';
  final wynik = <String>[];
  if (n >= 1000000) {
    final m = n ~/ 1000000;
    n %= 1000000;
    final mTxt = _slowa(m).trim();
    if (m == 1) {
      wynik.add('milion');
    } else if (m % 10 >= 2 && m % 10 <= 4 && !(m % 100 >= 12 && m % 100 <= 14)) {
      wynik.add('$mTxt miliony'.trim());
    } else {
      wynik.add('$mTxt milionów'.trim());
    }
  }
  if (n >= 1000) {
    final t = n ~/ 1000;
    n %= 1000;
    final tTxt = _slowa(t).trim();
    if (t == 1) {
      wynik.add('tysiąc');
    } else if (t % 10 >= 2 && t % 10 <= 4 && !(t % 100 >= 12 && t % 100 <= 14)) {
      wynik.add('$tTxt tysiące'.trim());
    } else {
      wynik.add('$tTxt tysięcy'.trim());
    }
  }
  final s = n ~/ 100;
  n %= 100;
  final d = n ~/ 10;
  final j = n % 10;
  if (s > 0) wynik.add(_set[s]);
  if (d == 1 && j > 0) {
    wynik.add(_naSt[j]);
  } else {
    if (d > 0) wynik.add(_dzies[d]);
    if (j > 0) wynik.add(_jedn[j]);
  }
  return wynik.where((w) => w.isNotEmpty).join(' ');
}

String _liczba(int n) => n == 0 ? 'zero' : _slowa(n);

String kwotaSlownie(String kwotaStr) {
  final clean = kwotaStr.replaceAll(',', '.').trim();
  final parsed = double.tryParse(clean);
  if (parsed == null || parsed < 0) return 'zero złotych zero groszy';
  final totalGr = (parsed * 100).round();
  final zl = totalGr ~/ 100;
  final gr = totalGr % 100;

  final zlTxt = _liczba(zl);
  final grTxt = _liczba(gr);

  String zlOdm;
  if (zl == 1) {
    zlOdm = 'złoty';
  } else if (zl % 10 >= 2 && zl % 10 <= 4 && !(zl % 100 >= 12 && zl % 100 <= 14)) {
    zlOdm = 'złote';
  } else {
    zlOdm = 'złotych';
  }

  String grOdm;
  if (gr == 1) {
    grOdm = 'grosz';
  } else if (gr % 10 >= 2 && gr % 10 <= 4 && !(gr % 100 >= 12 && gr % 100 <= 14)) {
    grOdm = 'grosze';
  } else {
    grOdm = 'groszy';
  }

  return '$zlTxt $zlOdm $grTxt $grOdm';
}
