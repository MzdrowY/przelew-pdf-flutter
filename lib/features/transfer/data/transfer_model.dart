class TransferData {
  final String nazwaOdbiorcy;
  final String nazwaOdbiorcyCd;
  final String nrRachunkuOdbiorcy;
  final String waluta;
  final String kwota;
  final String kwotaSlownie;
  final String tytulem;
  final String tytulemCd;

  const TransferData({
    required this.nazwaOdbiorcy,
    this.nazwaOdbiorcyCd = '',
    required this.nrRachunkuOdbiorcy,
    this.waluta = 'PLN',
    required this.kwota,
    required this.kwotaSlownie,
    required this.tytulem,
    this.tytulemCd = '',
  });
}
