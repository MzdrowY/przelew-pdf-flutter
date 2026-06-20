import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransferFormState {
  final String odbiorca;
  final String odbiorcaCd;
  final String konto;
  final String waluta;
  final String kwota;
  final String tytul1;
  final String tytul2;
  final String odcinek;

  const TransferFormState({
    this.odbiorca = '',
    this.odbiorcaCd = '',
    this.konto = '',
    this.waluta = 'PLN',
    this.kwota = '',
    this.tytul1 = '',
    this.tytul2 = '',
    this.odcinek = 'oba',
  });

  TransferFormState copyWith({
    String? odbiorca,
    String? odbiorcaCd,
    String? konto,
    String? waluta,
    String? kwota,
    String? tytul1,
    String? tytul2,
    String? odcinek,
  }) {
    return TransferFormState(
      odbiorca: odbiorca ?? this.odbiorca,
      odbiorcaCd: odbiorcaCd ?? this.odbiorcaCd,
      konto: konto ?? this.konto,
      waluta: waluta ?? this.waluta,
      kwota: kwota ?? this.kwota,
      tytul1: tytul1 ?? this.tytul1,
      tytul2: tytul2 ?? this.tytul2,
      odcinek: odcinek ?? this.odcinek,
    );
  }
}

class TransferNotifier extends StateNotifier<TransferFormState> {
  TransferNotifier() : super(const TransferFormState());

  void updateOdbiorca(String v) => state = state.copyWith(odbiorca: v);
  void updateOdbiorcaCd(String v) => state = state.copyWith(odbiorcaCd: v);
  void updateKonto(String v) => state = state.copyWith(konto: v);
  void updateWaluta(String v) => state = state.copyWith(waluta: v);
  void updateKwota(String v) => state = state.copyWith(kwota: v);
  void updateTytul1(String v) => state = state.copyWith(tytul1: v);
  void updateTytul2(String v) => state = state.copyWith(tytul2: v);
  void updateOdcinek(String v) => state = state.copyWith(odcinek: v);

  void loadFromPayee({
    required String odbiorca,
    required String odbiorcaCd,
    required String konto,
    required String kwota,
    String? tytul1,
    String? tytul2,
  }) {
    state = state.copyWith(
      odbiorca: odbiorca,
      odbiorcaCd: odbiorcaCd,
      konto: konto,
      kwota: kwota,
      tytul1: tytul1,
      tytul2: tytul2,
    );
  }

  void loadFromHistory({
    required String odbiorca,
    required String odbiorcaCd,
    required String konto,
    required String waluta,
    required String kwota,
    required String tytul1,
    required String tytul2,
    required String odcinek,
  }) {
    state = TransferFormState(
      odbiorca: odbiorca,
      odbiorcaCd: odbiorcaCd,
      konto: konto,
      waluta: waluta,
      kwota: kwota,
      tytul1: tytul1,
      tytul2: tytul2,
      odcinek: odcinek,
    );
  }

  void reset() {
    state = const TransferFormState();
  }
}

final transferFormProvider = StateNotifierProvider<TransferNotifier, TransferFormState>((ref) {
  return TransferNotifier();
});
