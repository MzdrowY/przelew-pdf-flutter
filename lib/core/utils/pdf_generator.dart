import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../constants/field_positions.dart';

class PdfGenerator {
  PdfGenerator._();

  static pw.Font? _font;
  static pw.MemoryImage? _templateImage;

  static Future<pw.Font> _loadFont() async {
    if (_font != null) return _font!;
    // 1) Courier New Bold (assets)
    try {
      final data = await rootBundle.load('assets/fonts/courbd.ttf');
      _font = pw.Font.ttf(data);
      return _font!;
    } catch (_) {}
    // 2) Courier New Regular (assets)
    try {
      final data = await rootBundle.load('assets/fonts/cour.ttf');
      _font = pw.Font.ttf(data);
      return _font!;
    } catch (_) {}
    // 3) Systemowy Courier New Bold
    try {
      final fontFile = File(r'C:\Windows\Fonts\courbd.ttf');
      if (await fontFile.exists()) {
        final data = await fontFile.readAsBytes();
        _font = pw.Font.ttf(ByteData.view(data.buffer));
        return _font!;
      }
    } catch (_) {}
    // 4) Systemowy Courier New Regular
    try {
      final fontFile = File(r'C:\Windows\Fonts\cour.ttf');
      if (await fontFile.exists()) {
        final data = await fontFile.readAsBytes();
        _font = pw.Font.ttf(ByteData.view(data.buffer));
        return _font!;
      }
    } catch (_) {}
    // 5) Fallback Roboto
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    _font = pw.Font.ttf(fontData);
    return _font!;
  }

  static Future<pw.MemoryImage> _loadTemplate() async {
    if (_templateImage != null) return _templateImage!;
    final bytes = await rootBundle.load('assets/images/blankiet.png');
    _templateImage = pw.MemoryImage(bytes.buffer.asUint8List());
    return _templateImage!;
  }

  static Future<Uint8List> generate({
    required String nazwaOdbiorcy,
    required String nazwaOdbiorcyCd,
    required String nrRachunkuOdbiorcy,
    required String waluta,
    required String kwota,
    required String kwotaSlownie,
    required String nazwaZleceniodawcy,
    required String adresZleceniodawcy,
    required String kontoZleceniodawcy,
    required String tytulem,
    required String tytulemCd,
    required bool wplataGotowkowa,
    required String odcinek,
    double shiftX = 0,
    double shiftY = 0,
    double fontSize = 11,
    double offsetY = 0,
    double cellW = 0,
  }) async {
    final font = await _loadFont();
    final template = await _loadTemplate();
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (ctx) {
          final widgets = <pw.Widget>[];

          widgets.add(pw.Positioned.fill(
            child: pw.Image(template, fit: pw.BoxFit.fill),
          ));

          final topY = FieldPositions.bottomOffsetPx;
          final formData = _FormData(
            nazwaOdbiorcy: nazwaOdbiorcy,
            nazwaOdbiorcyCd: nazwaOdbiorcyCd,
            nrRachunkuOdbiorcy: nrRachunkuOdbiorcy,
            waluta: waluta,
            kwota: kwota,
            kwotaSlownie: kwotaSlownie,
            nazwaZleceniodawcy: nazwaZleceniodawcy,
            adresZleceniodawcy: adresZleceniodawcy,
            kontoZleceniodawcy: kontoZleceniodawcy,
            tytulem: tytulem,
            tytulemCd: tytulemCd,
            wplataGotowkowa: wplataGotowkowa,
            shiftX: shiftX,
            shiftY: shiftY,
            offsetY: offsetY,
            cellW: cellW,
            fontSize: fontSize,
          );
          if (odcinek == 'gorny' || odcinek == 'oba') {
            _addFields(widgets, 0, font, formData);
          }
          if (odcinek == 'dolny' || odcinek == 'oba') {
            _addFields(widgets, topY, font, formData);
          }
          return pw.Stack(children: widgets);
        },
      ),
    );

    return doc.save();
  }

  static void _addFields(List<pw.Widget> widgets, double yOff, pw.Font font, _FormData d) {
    final nfs = d.fontSize * (9.0 / 11.0);
    final ifs = d.fontSize * (10.0 / 11.0);
    final sfs = d.fontSize * (8.5 / 11.0);

    void wf(String t, double x, double y, double h, int cc, double cs, double cw, double fs,
        {bool fillDashes = false}) {
      _writeCellField(widgets, t, x + d.shiftX, y + yOff + d.shiftY, h, cc, cs, cw, font, fs,
          fillDashes: fillDashes, offsetY: d.offsetY, cellW: d.cellW);
    }

    wf(d.nazwaOdbiorcy,      FieldPositions.nazwaOdbiorcyXPx,    FieldPositions.nazwaOdbiorcyTop,      FieldPositions.nazwaOdbiorcyH,      27, FieldPositions.cellStep27Px, FieldPositions.cellWidth27Px, nfs);
    wf(d.nazwaOdbiorcyCd,    FieldPositions.nazwaOdbiorcyXPx,    FieldPositions.nazwaOdbiorcyCdTop,    FieldPositions.nazwaOdbiorcyCdH,    27, FieldPositions.cellStep27Px, FieldPositions.cellWidth27Px, nfs);
    wf(d.nrRachunkuOdbiorcy, FieldPositions.nrRachunkuOdbiorcyXPx, FieldPositions.nrRachunkuOdbiorcyTop, FieldPositions.nrRachunkuOdbiorcyH, 26, FieldPositions.cellStep26Px, FieldPositions.cellWidth26Px, ifs);
    wf(d.waluta.toUpperCase(), FieldPositions.walutaXPx,        FieldPositions.kwotaTop,              FieldPositions.kwotaH,               3, FieldPositions.walutaStepPx, FieldPositions.cellWidth27Px, sfs);
    wf(d.kwota, FieldPositions.kwotaXPx,     FieldPositions.kwotaTop,              FieldPositions.kwotaH,              12, FieldPositions.kwotaStepPx, FieldPositions.kwotaCellWidthPx, sfs,
        fillDashes: true);
    if (d.wplataGotowkowa) {
      wf(d.kwotaSlownie,
          FieldPositions.rachunekZleceniodawcyXPx, FieldPositions.rachunekZleceniodawcyTop,
          FieldPositions.rachunekZleceniodawcyH,
          26, FieldPositions.cellStep26Px, FieldPositions.cellWidth26Px, ifs,
          fillDashes: true);
    } else {
      wf(d.kontoZleceniodawcy, FieldPositions.rachunekZleceniodawcyXPx,
          FieldPositions.rachunekZleceniodawcyTop,
          FieldPositions.rachunekZleceniodawcyH,
          26, FieldPositions.cellStep26Px, FieldPositions.cellWidth26Px, ifs);
    }
    wf(d.nazwaZleceniodawcy, FieldPositions.nadawcaNazwaXPx,    FieldPositions.nadawcaNazwaTop,       FieldPositions.nadawcaNazwaH,       27, FieldPositions.cellStep27Px, FieldPositions.cellWidth27Px, nfs);
    wf(d.adresZleceniodawcy, FieldPositions.nadawcaNazwaXPx,    FieldPositions.nadawcaAdresTop,       FieldPositions.nadawcaAdresH,       27, FieldPositions.cellStep27Px, FieldPositions.cellWidth27Px, nfs);
    wf(d.tytulem,            FieldPositions.tytulemXPx,          FieldPositions.tytulemTop,            FieldPositions.tytulemH,            27, FieldPositions.cellStep27Px, FieldPositions.cellWidth27Px, nfs);
    wf(d.tytulemCd,          FieldPositions.tytulemXPx,          FieldPositions.tytulemCdTop,          FieldPositions.tytulemCdH,          27, FieldPositions.cellStep27Px, FieldPositions.cellWidth27Px, nfs);
  }

  /// Kazdy znak jako osobny pw.Text — wycentrowany w kratce.
  /// Courier New = monospace: kazda litera ma ta sama szerokosc.
  /// [squeeze]=true: jesli tekst dluzszy niz [cellCount], kazdy znak
  /// wciaz osobno ale krok proporcjonalnie mniejszy zeby zmiescic sie
  /// w tej samej szerokosci (kwota slownie gdy nie miesci sie w 26 polach).
  static void _writeCellField(List<pw.Widget> widgets, String text,
      double xStartPx, double topYPx, double fieldHeightPx,
      int cellCount, double cellStepPx, double cellWidthPx,
      pw.Font font, double fontSizePt,
      {bool fillDashes = false, double offsetY = 0, double cellW = 0}) {
    if (text.isEmpty) return;

    final pt = FieldPositions.pxToPt;
    final startPt = xStartPx * pt;
    final topYPt = topYPx * pt;
    final fhPt = fieldHeightPx * pt;
    final stepPt = cellStepPx * pt;

    // ZAWSZE squeeze gdy tekst dluzszy niz komorki — tekst nie moze wyjezdzac poza blankiet
    final bool doSqueeze = text.length > cellCount;
    final double ratio = doSqueeze ? cellCount / text.length : 1.0;
    final double effStepPt = stepPt * ratio;
    final double charRatio = (cellW > 0 ? cellW / 5.0 * 0.6 : 0.6);
    final double effCharW = fontSizePt * charRatio * ratio;
    // Centrowanie pionowe z oryginalnym fontem
    final textTop = topYPt + (fhPt - fontSizePt) / 2.0 + offsetY;

    final int limit = doSqueeze ? text.length : (fillDashes ? cellCount : text.length);
    for (int i = 0; i < limit; i++) {
      final String ch = i < text.length ? text[i] : (fillDashes ? '-' : ' ');
      if (ch == ' ') continue;

      final cellLeft = startPt + i * effStepPt;
      final double halfGap = (effStepPt - effCharW) / 2.0;
      final charLeft = cellLeft + halfGap;

      widgets.add(
        pw.Positioned(
          left: charLeft,
          top: textTop,
          child: pw.Text(
            ch,
            textDirection: pw.TextDirection.ltr,
            style: pw.TextStyle(
              fontSize: fontSizePt,
              font: font,
              color: PdfColors.black,
            ),
          ),
        ),
      );
    }
  }
}

class _FormData {
  final String nazwaOdbiorcy;
  final String nazwaOdbiorcyCd;
  final String nrRachunkuOdbiorcy;
  final String waluta;
  final String kwota;
  final String kwotaSlownie;
  final String nazwaZleceniodawcy;
  final String adresZleceniodawcy;
  final String kontoZleceniodawcy;
  final String tytulem;
  final String tytulemCd;
  final bool wplataGotowkowa;
  final double shiftX;
  final double shiftY;
  final double offsetY;
  final double cellW;
  final double fontSize;

  const _FormData({
    required this.nazwaOdbiorcy,
    required this.nazwaOdbiorcyCd,
    required this.nrRachunkuOdbiorcy,
    required this.waluta,
    required this.kwota,
    required this.kwotaSlownie,
    required this.nazwaZleceniodawcy,
    required this.adresZleceniodawcy,
    required this.kontoZleceniodawcy,
    required this.tytulem,
    required this.tytulemCd,
    required this.wplataGotowkowa,
    this.shiftX = 0,
    this.shiftY = 0,
    this.offsetY = 0,
    this.cellW = 0,
    required this.fontSize,
  });
}
