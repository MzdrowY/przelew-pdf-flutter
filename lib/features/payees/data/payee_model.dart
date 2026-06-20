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
    'odbiorca': odbiorca,
    'odbiorcaCd': odbiorcaCd,
    'konto': konto.replaceAll(RegExp(r'\s+'), ''),
    'kwota': kwota,
    'tytul': tytul,
    'tytulCd': tytulCd,
  };

  factory PayeeModel.fromJson(String alias, Map<String, dynamic> json) {
    // New format stores lines separately; old format joined them with '\n'.
    String odbiorca = '';
    String odbiorcaCd = '';
    if (json['odbiorca'] is String) {
      final raw = json['odbiorca'] as String;
      if (json['odbiorcaCd'] is String) {
        odbiorca = raw;
        odbiorcaCd = json['odbiorcaCd'] as String;
      } else {
        final lines = raw.split('\n');
        odbiorca = lines.isNotEmpty ? lines[0] : '';
        odbiorcaCd = lines.length > 1 ? lines[1] : '';
      }
    }
    String tytul = '';
    String tytulCd = '';
    if (json['tytul'] is String) {
      final raw = json['tytul'] as String;
      if (json['tytulCd'] is String) {
        tytul = raw;
        tytulCd = json['tytulCd'] as String;
      } else {
        final lines = raw.split('\n');
        tytul = lines.isNotEmpty ? lines[0] : '';
        tytulCd = lines.length > 1 ? lines[1] : '';
      }
    }
    return PayeeModel(
      alias: alias,
      odbiorca: odbiorca,
      odbiorcaCd: odbiorcaCd,
      konto: json['konto'] as String? ?? '',
      kwota: json['kwota'] as String? ?? '',
      tytul: tytul,
      tytulCd: tytulCd,
    );
  }
}
