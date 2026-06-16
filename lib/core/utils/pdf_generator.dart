import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../constants/field_positions.dart';

class PdfGenerator {
  PdfGenerator._();

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
    required double shiftX,
    required double shiftY,
    required double fontSize,
    required double offsetY,
    required double cellW,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (ctx) {
          return pw.Container(
            width: double.infinity,
            height: double.infinity,
            decoration: pw.BoxDecoration(),
            child: pw.Stack(
              children: [
                pw.Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 0.5),
                  ),
                ),
                if (odcinek == 'gorny' || odcinek == 'oba')
                  _buildSection(FieldPositions.top, _FormData(
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
                    fontSize: fontSize,
                    offsetY: offsetY,
                    cellW: cellW,
                  )),
                if (odcinek == 'dolny' || odcinek == 'oba')
                  _buildSection(FieldPositions.bottom, _FormData(
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
                    fontSize: fontSize,
                    offsetY: offsetY,
                    cellW: cellW,
                  )),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildSection(FieldSection section, _FormData data) {
    final fields = <pw.Widget>[];
    _addField(data.nazwaOdbiorcy, section.nazwaOdbiorcy, data, fields);
    _addField(data.nazwaOdbiorcyCd, section.nazwaOdbiorcyCd, data, fields);
    _addField(data.nrRachunkuOdbiorcy, section.nrRachunkuOdbiorcy, data, fields, maxCells: 26);
    _addField(data.waluta, section.waluta, data, fields, maxCells: 3);
    _addField(data.kwota.padRight(12, '-'), section.kwota, data, fields, maxCells: 12);
    _addField(
      data.wplataGotowkowa ? data.kwotaSlownie : data.kontoZleceniodawcy,
      section.rachunekZleceniodawcy,
      data,
      fields,
    );
    _addField(data.nazwaZleceniodawcy, section.nadawcaNazwa, data, fields);
    _addField(data.adresZleceniodawcy, section.nadawcaAdres, data, fields);
    _addField(data.tytulem, section.tytulem, data, fields);
    _addField(data.tytulemCd, section.tytulemCd, data, fields);
    return pw.Stack(children: fields);
  }

  static void _addField(String text, FieldPoint pos, _FormData data, List<pw.Widget> fields, {int maxCells = 26}) {
    if (text.isEmpty) return;
    final x = (pos.x + data.shiftX) * FieldPositions.mmToPt;
    final y = (pos.y + data.shiftY + data.offsetY) * FieldPositions.mmToPt;
    fields.add(
      pw.Positioned(
        left: x,
        top: y,
        child: pw.Text(
          text,
          textDirection: pw.TextDirection.ltr,
          style: pw.TextStyle(
            fontSize: data.fontSize,
            font: pw.Font.helvetica(),
            color: PdfColors.black,
          ),
        ),
      ),
    );
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
  final double fontSize;
  final double offsetY;
  final double cellW;

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
    required this.shiftX,
    required this.shiftY,
    required this.fontSize,
    required this.offsetY,
    required this.cellW,
  });
}
