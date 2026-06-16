class PayeeModel {
  final String alias;
  final String odbiorca;
  final String odbiorcaCd;
  final String konto;
  final String kwota;
  final String tytul;
  final String tytulCd;

  const PayeeModel({
    required this.alias,
    this.odbiorca = '',
    this.odbiorcaCd = '',
    this.konto = '',
    this.kwota = '',
    this.tytul = '',
    this.tytulCd = '',
  });

  Map<String, dynamic> toJson() => {
    'odbiorca': [odbiorca, odbiorcaCd].where((e) => e.isNotEmpty).join('\n'),
    'konto': konto.replaceAll(RegExp(r'\s+'), ''),
    'kwota': kwota,
    'tytul': [tytul, tytulCd].where((e) => e.isNotEmpty).join('\n'),
  };

  factory PayeeModel.fromJson(String alias, Map<String, dynamic> json) {
    final odbLines = (json['odbiorca'] as String? ?? '').split('\n');
    final tytLines = (json['tytul'] as String? ?? '').split('\n');
    return PayeeModel(
      alias: alias,
      odbiorca: odbLines.isNotEmpty ? odbLines[0] : '',
      odbiorcaCd: odbLines.length > 1 ? odbLines[1] : '',
      konto: json['konto'] as String? ?? '',
      kwota: json['kwota'] as String? ?? '',
      tytul: tytLines.isNotEmpty ? tytLines[0] : '',
      tytulCd: tytLines.length > 1 ? tytLines[1] : '',
    );
  }
}
