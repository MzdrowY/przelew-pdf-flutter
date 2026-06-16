class IbanValidator {
  IbanValidator._();

  static (bool, String?) validate(String raw) {
    final clean = raw.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    if (RegExp(r'^\d{26}$').hasMatch(clean)) {
      return (true, clean);
    }
    if (RegExp(r'^PL\d{26}$').hasMatch(clean)) {
      return (true, clean.substring(2));
    }
    return (false, null);
  }

  static bool checkMod97(String nrb26) {
    final digits = nrb26.replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^\d{26}$').hasMatch(digits)) return false;
    final iban = 'PL$digits';
    final rearranged = '${iban.substring(4)}${iban.substring(0, 4)}';
    final numeric = rearranged.split('').map((ch) {
      if (ch.contains(RegExp(r'[A-Z]'))) {
        return (ch.codeUnitAt(0) - 'A'.codeUnitAt(0) + 10).toString();
      }
      return ch;
    }).join();
    return _bigMod97(numeric) == 1;
  }

  static int _bigMod97(String digits) {
    int remainder = 0;
    for (var i = 0; i < digits.length; i++) {
      remainder = (remainder * 10 + int.parse(digits[i])) % 97;
    }
    return remainder;
  }

  static String format(String nrb26) {
    final clean = nrb26.replaceAll(RegExp(r'\s+'), '');
    if (clean.length != 26) return clean;
    final parts = <String>[];
    for (var i = 0; i < clean.length; i += 4) {
      parts.add(clean.substring(i, (i + 4).clamp(0, clean.length)));
    }
    return parts.join(' ');
  }
}
