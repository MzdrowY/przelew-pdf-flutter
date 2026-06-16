import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/iban_validator.dart';
import '../../../core/utils/kwota_slownie.dart';
import 'transfer_model.dart';

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepository();
});

class TransferRepository {
  (bool, String?) validateKonto(String raw) => IbanValidator.validate(raw);
  bool checkMod97(String nrb) => IbanValidator.checkMod97(nrb);
  String formatKonto(String nrb) => IbanValidator.format(nrb);

  (bool, String?) validateKwota(String raw) {
    try {
      final kw = double.tryParse(raw.replaceAll(',', '.').trim());
      if (kw == null || kw <= 0) return (false, null);
      return (true, kw.toStringAsFixed(2).replaceAll('.', ','));
    } catch (_) {
      return (false, null);
    }
  }

  TransferData buildTransferData({
    required String odbiorca,
    required String odbiorcaCd,
    required String konto,
    required String waluta,
    required String kwota,
    required String tytul1,
    required String tytul2,
  }) {
    final kwotaSl = kwotaSlownie(kwota.replaceAll(',', '.').trim());
    return TransferData(
      nazwaOdbiorcy: odbiorca,
      nazwaOdbiorcyCd: odbiorcaCd,
      nrRachunkuOdbiorcy: konto.replaceAll(RegExp(r'\s+'), ''),
      waluta: waluta.isEmpty ? 'PLN' : waluta.toUpperCase(),
      kwota: kwota,
      kwotaSlownie: kwotaSl,
      tytulem: tytul1,
      tytulemCd: tytul2,
    );
  }
}
