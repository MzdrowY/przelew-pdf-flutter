class FieldSection {
  final FieldPoint nazwaOdbiorcy;
  final FieldPoint nazwaOdbiorcyCd;
  final FieldPoint nrRachunkuOdbiorcy;
  final FieldPoint waluta;
  final FieldPoint kwota;
  final FieldPoint rachunekZleceniodawcy;
  final FieldPoint nadawcaNazwa;
  final FieldPoint nadawcaAdres;
  final FieldPoint tytulem;
  final FieldPoint tytulemCd;

  const FieldSection({
    required this.nazwaOdbiorcy,
    required this.nazwaOdbiorcyCd,
    required this.nrRachunkuOdbiorcy,
    required this.waluta,
    required this.kwota,
    required this.rachunekZleceniodawcy,
    required this.nadawcaNazwa,
    required this.nadawcaAdres,
    required this.tytulem,
    required this.tytulemCd,
  });
}

class FieldPoint {
  final double x;
  final double y;
  const FieldPoint(this.x, this.y);
}

class FieldPositions {
  FieldPositions._();

  static const mmToPt = 2.83465;

  static const top = FieldSection(
    nazwaOdbiorcy: FieldPoint(38.1000, 20.1507),
    nazwaOdbiorcyCd: FieldPoint(38.1000, 28.7867),
    nrRachunkuOdbiorcy: FieldPoint(38.1000, 37.0840),
    waluta: FieldPoint(93.6413, 46.2280),
    kwota: FieldPoint(113.792, 46.0587),
    rachunekZleceniodawcy: FieldPoint(38.1000, 54.5253),
    nadawcaNazwa: FieldPoint(38.1000, 62.4840),
    nadawcaAdres: FieldPoint(38.1000, 70.7813),
    tytulem: FieldPoint(38.1000, 79.9253),
    tytulemCd: FieldPoint(38.1000, 87.8840),
  );

  static const bottom = FieldSection(
    nazwaOdbiorcy: FieldPoint(38.1000, 129.3707),
    nazwaOdbiorcyCd: FieldPoint(38.1000, 138.6840),
    nrRachunkuOdbiorcy: FieldPoint(38.1000, 146.8120),
    waluta: FieldPoint(93.4720, 155.6173),
    kwota: FieldPoint(113.9613, 155.6173),
    rachunekZleceniodawcy: FieldPoint(38.1000, 163.2373),
    nadawcaNazwa: FieldPoint(38.1000, 172.2120),
    nadawcaAdres: FieldPoint(38.1000, 181.0173),
    tytulem: FieldPoint(38.1000, 189.3147),
    tytulemCd: FieldPoint(38.1000, 197.7813),
  );
}
