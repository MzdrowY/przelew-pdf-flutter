import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/utils/iban_validator.dart';
import '../../../shared/widgets/accent_card.dart';
import '../../../shared/widgets/side_rail.dart';
import '../../payees/data/payee_model.dart';
import '../../payees/domain/payee_notifier.dart';
import '../../settings/domain/settings_notifier.dart';
import '../data/transfer_repository.dart';
import '../domain/transfer_notifier.dart';
import 'widgets/calibration_section.dart';

class TransferFormPage extends ConsumerStatefulWidget {
  const TransferFormPage({super.key});

  @override
  ConsumerState<TransferFormPage> createState() => _TransferFormPageState();
}

class _TransferFormPageState extends ConsumerState<TransferFormPage> {
  late final TextEditingController _odbiorcaCtrl;
  late final TextEditingController _odbiorcaCdCtrl;
  late final TextEditingController _kontoCtrl;
  late final TextEditingController _walutaCtrl;
  late final TextEditingController _kwotaCtrl;
  late final TextEditingController _tytul1Ctrl;
  late final TextEditingController _tytul2Ctrl;
  late final TextEditingController _senderNazwaCtrl;
  late final TextEditingController _senderAdresCtrl;
  late final TextEditingController _senderKontoCtrl;
  bool _wplataGotowkowa = true;
  String _odcinek = 'oba';

  @override
  void initState() {
    super.initState();
    final f = ref.read(transferFormProvider);
    _odbiorcaCtrl = TextEditingController(text: f.odbiorca);
    _odbiorcaCdCtrl = TextEditingController(text: f.odbiorcaCd);
    _kontoCtrl = TextEditingController(text: f.konto);
    _walutaCtrl = TextEditingController(text: f.waluta);
    _kwotaCtrl = TextEditingController(text: f.kwota);
    _tytul1Ctrl = TextEditingController(text: f.tytul1);
    _tytul2Ctrl = TextEditingController(text: f.tytul2);
    _senderNazwaCtrl = TextEditingController();
    _senderAdresCtrl = TextEditingController();
    _senderKontoCtrl = TextEditingController();
    _odcinek = f.odcinek;
  }

  @override
  void dispose() {
    _odbiorcaCtrl.dispose(); _odbiorcaCdCtrl.dispose(); _kontoCtrl.dispose();
    _walutaCtrl.dispose(); _kwotaCtrl.dispose(); _tytul1Ctrl.dispose();
    _tytul2Ctrl.dispose(); _senderNazwaCtrl.dispose(); _senderAdresCtrl.dispose();
    _senderKontoCtrl.dispose();
    super.dispose();
  }

  void _syncSender(Map<String, dynamic> s) {
    final nazwa = s['nazwa'] as String? ?? '';
    final adres = s['adres'] as String? ?? '';
    final konto = s['konto_zleceniodawcy'] as String? ?? '';
    final wplata = s['wplata_gotowkowa'] as bool? ?? true;
    if (_senderNazwaCtrl.text != nazwa) _senderNazwaCtrl.text = nazwa;
    if (_senderAdresCtrl.text != adres) _senderAdresCtrl.text = adres;
    if (_senderKontoCtrl.text != konto) _senderKontoCtrl.text = konto;
    if (_wplataGotowkowa != wplata) _wplataGotowkowa = wplata;
  }

  void _syncFormFromState() {
    final f = ref.read(transferFormProvider);
    if (_odbiorcaCtrl.text != f.odbiorca) _odbiorcaCtrl.text = f.odbiorca;
    if (_odbiorcaCdCtrl.text != f.odbiorcaCd) _odbiorcaCdCtrl.text = f.odbiorcaCd;
    if (_kontoCtrl.text != f.konto) _kontoCtrl.text = f.konto;
    if (_walutaCtrl.text != f.waluta) _walutaCtrl.text = f.waluta;
    if (_kwotaCtrl.text != f.kwota) _kwotaCtrl.text = f.kwota;
    if (_tytul1Ctrl.text != f.tytul1) _tytul1Ctrl.text = f.tytul1;
    if (_tytul2Ctrl.text != f.tytul2) _tytul2Ctrl.text = f.tytul2;
    if (_odcinek != f.odcinek) _odcinek = f.odcinek;
  }

  void _loadFromHistory(Map<String, String> entry) {
    ref.read(transferFormProvider.notifier).loadFromHistory(
      odbiorca: entry['odbiorca'] ?? '',
      odbiorcaCd: entry['odbiorcaCd'] ?? '',
      konto: entry['konto'] ?? '',
      waluta: entry['waluta'] ?? 'PLN',
      kwota: entry['kwota'] ?? '',
      tytul1: entry['tytul1'] ?? '',
      tytul2: entry['tytul2'] ?? '',
      odcinek: entry['odcinek'] ?? 'oba',
    );
  }

  void _saveSender() {
    ref.read(settingsStateProvider.notifier).update({
      'nazwa': _senderNazwaCtrl.text, 'adres': _senderAdresCtrl.text,
      'konto_zleceniodawcy': _senderKontoCtrl.text, 'wplata_gotowkowa': _wplataGotowkowa,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final settings = ref.watch(settingsStateProvider);
    final history = ref.watch(historyListProvider);
    ref.watch(transferFormProvider);
    _syncSender(settings);
    _syncFormFromState();

    return Scaffold(
      body: Row(
        children: [
          SideRail(
            items: const [
              NavItem(Icons.receipt_long, 'Formularz', '/'),
              NavItem(Icons.people, 'Odbiorcy', '/payees', activeIcon: Icons.people_alt),
              NavItem(Icons.history, 'Historia', '/history', activeIcon: Icons.access_time_filled),
              NavItem(Icons.tune, 'Ustawienia', '/settings', activeIcon: Icons.settings_applications),
            ],
            selectedIndex: 0,
            onDestinationSelected: (_, r) => context.push(r),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [colors.backgroundTop, colors.surface, colors.backgroundTop],
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: [
                  _buildHeader(context, colors),
                  const SizedBox(height: 8),
                  _buildSenderSection(colors),
                  const SizedBox(height: 12),
                  _buildPayeeSection(colors),
                  const SizedBox(height: 12),
                  _buildDetailsSection(colors),
                  const SizedBox(height: 12),
                  const CalibrationSection(),
                  const SizedBox(height: 12),
                  _buildOptionsSection(colors),
                  const SizedBox(height: 16),
                  _buildGenerateButton(colors),
                  if (history.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildHistorySection(history, colors),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border, width: .5)),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [colors.primary, colors.primaryGlow]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.account_balance, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text('Polecenie przelewu PDF', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary, letterSpacing: -.3,
          )),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSenderSection(AppThemeColors colors) {
    return AccentCard(
      accentColor: colors.accent,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.person_outline, 'Zleceniodawca', colors, _senderToggle(colors)),
        const SizedBox(height: 12),
        _field(Icons.account_circle_outlined, 'Nazwa', _senderNazwaCtrl, colors, onChanged: (_) => _saveSender()),
        const SizedBox(height: 8),
        _field(Icons.location_on_outlined, 'Adres', _senderAdresCtrl, colors, maxLines: 2, onChanged: (_) => _saveSender()),
        if (!_wplataGotowkowa) ...[const SizedBox(height: 8), _field(Icons.account_balance_outlined, 'Nr konta', _senderKontoCtrl, colors, onChanged: (_) => _saveSender())],
      ]),
    );
  }

  Widget _buildPayeeSection(AppThemeColors colors) {
    final payees = ref.watch(payeeStateProvider);
    final aliases = payees.keys.toList()..sort();
    return AccentCard(
      accentColor: colors.primary,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.people_alt_outlined, 'Odbiorca', colors, TextButton(onPressed: () => context.push('/payees'), child: const Text('Edytuj', style: TextStyle(fontSize: 11)))),
        const SizedBox(height: 12),
        if (aliases.isNotEmpty)
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Wybierz z bazy',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: colors.field,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            dropdownColor: colors.surface, isDense: true,
            style: TextStyle(fontSize: 13, color: colors.textPrimary),
            items: aliases.map((a) => DropdownMenuItem(value: a, child: Text(a, style: TextStyle(fontSize: 13, color: colors.textPrimary)))).toList(),
            onChanged: (alias) {
              if (alias == null) return; final p = payees[alias]; if (p == null) return;
              _odbiorcaCtrl.text = p.odbiorca; _odbiorcaCdCtrl.text = p.odbiorcaCd; _kontoCtrl.text = p.konto;
              _kwotaCtrl.text = p.kwota; _tytul1Ctrl.text = p.tytul; _tytul2Ctrl.text = p.tytulCd;
              ref.read(transferFormProvider.notifier).loadFromPayee(
                odbiorca: p.odbiorca,
                odbiorcaCd: p.odbiorcaCd,
                konto: p.konto,
                kwota: p.kwota,
                tytul1: p.tytul,
                tytul2: p.tytulCd,
              );
            },
          )
        else Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('Brak odbiorców — dodaj poniżej', style: Theme.of(context).textTheme.bodyMedium)),
      ]),
    );
  }

  Widget _buildDetailsSection(AppThemeColors colors) {
    return AccentCard(
      accentColor: const Color(0xFFFFA07A),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.receipt_long_outlined, 'Szczegóły przelewu', colors, TextButton(onPressed: _clearAll, child: const Text('Wyczyść', style: TextStyle(fontSize: 11)))),
        const SizedBox(height: 12),
        _field(Icons.person_outline, 'Odbiorca (linia 1)', _odbiorcaCtrl, colors, onChanged: (v) => ref.read(transferFormProvider.notifier).updateOdbiorca(v)),
        const SizedBox(height: 8),
        _field(null, 'Odbiorca (linia 2)', _odbiorcaCdCtrl, colors, onChanged: (v) => ref.read(transferFormProvider.notifier).updateOdbiorcaCd(v)),
        const SizedBox(height: 8),
        _field(Icons.credit_card_outlined, 'Nr konta', _kontoCtrl, colors, onChanged: _formatIban),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(flex: 1, child: _field(Icons.currency_exchange_outlined, 'Waluta', _walutaCtrl, colors, onChanged: (v) => ref.read(transferFormProvider.notifier).updateWaluta(v))),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: _field(Icons.payments_outlined, 'Kwota', _kwotaCtrl, colors, onChanged: (v) => ref.read(transferFormProvider.notifier).updateKwota(v))),
        ]),
        const SizedBox(height: 8),
        _field(Icons.subject_outlined, 'Tytułem (linia 1)', _tytul1Ctrl, colors, onChanged: (v) => ref.read(transferFormProvider.notifier).updateTytul1(v)),
        const SizedBox(height: 8),
        _field(null, 'Tytułem (linia 2)', _tytul2Ctrl, colors, onChanged: (v) => ref.read(transferFormProvider.notifier).updateTytul2(v)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _actionBtn(Icons.bookmark_outline, 'Zapisz odbiorcę', colors, () => _quickSavePayee())),
          const SizedBox(width: 8),
          Expanded(child: _actionBtn(Icons.preview_outlined, 'Podgląd', colors, () => _validateAndProceed(context, ref.read(transferFormProvider), colors))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _actionBtn(Icons.delete_forever_outlined, 'Wyczyść wszystko', colors, _clearAll)),
        ]),
      ]),
    );
  }

  Widget _buildOptionsSection(AppThemeColors colors) {
    return AccentCard(
      accentColor: colors.primarySoft,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.print_outlined, 'Opcje wydruku', colors),
        const SizedBox(height: 12),
        Row(children: ['Oba odcinki', 'Górny', 'Dolny'].asMap().entries.map((e) {
          final map = {'Oba odcinki': 'oba', 'Górny': 'gorny', 'Dolny': 'dolny'};
          final v = map[e.value]!; final sel = _odcinek == v;
          return Expanded(
            child: GestureDetector(
              onTap: () { setState(() => _odcinek = v); ref.read(transferFormProvider.notifier).updateOdcinek(v); },
              child: Container(
                margin: EdgeInsets.only(right: e.key < 2 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? colors.primary.withValues(alpha: .12) : colors.field,
                  borderRadius: BorderRadius.circular(10),
                  border: sel ? Border.all(color: colors.primary.withValues(alpha: .4)) : Border.all(color: colors.border.withValues(alpha: .3)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(sel ? Icons.check_circle : Icons.radio_button_unchecked, size: 14, color: sel ? colors.primarySoft : colors.textTertiary),
                  const SizedBox(width: 4), Text(e.value, style: TextStyle(fontSize: 11, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? colors.primarySoft : colors.textSecondary)),
                ]),
              ),
            ),
          );
        }).toList()),
      ]),
    );
  }

  Widget _buildGenerateButton(AppThemeColors colors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: [colors.primary, colors.primaryGlow]),
        boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: .30), blurRadius: 24, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _validateAndProceed(context, ref.read(transferFormProvider), colors),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('GENERUJ PDF', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(List<Map<String, String>> history, AppThemeColors colors) {
    final recent = history.take(5).toList();
    return AccentCard(
      accentColor: colors.success,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.access_time, 'Ostatnie przelewy', colors),
        const SizedBox(height: 12),
        ...recent.map((e) => Row(children: [
          Expanded(child: GestureDetector(
            onTap: () { _loadFromHistory(e); context.push('/preview'); },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(10), border: Border.all(color: colors.border.withValues(alpha: .2))),
              child: Row(children: [
                SizedBox(width: 70, child: Text(e['data'] ?? '', style: TextStyle(fontSize: 11, color: colors.textTertiary))),
                Expanded(child: Text(e['odbiorca'] ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.textPrimary), overflow: TextOverflow.ellipsis, maxLines: 1)),
                Text(e['kwota'] ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.success)),
              ]),
            ),
          )),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: IconButton(
              icon: Icon(Icons.edit, size: 14, color: colors.textTertiary),
              onPressed: () { _loadFromHistory(e); },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Edytuj w formularzu',
            ),
          ),
        ])),
      ]),
    );
  }

  // ---------- HELPERS ----------
  Widget _sectionHeader(IconData icon, String label, AppThemeColors colors, [Widget? trailing]) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: colors.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: colors.primarySoft)),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
      if (trailing != null) ...[const Spacer(), trailing],
    ]);
  }

  Widget _field(IconData? icon, String label, TextEditingController ctrl, AppThemeColors colors, {int maxLines = 1, void Function(String)? onChanged, TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl, maxLines: maxLines, onChanged: onChanged, keyboardType: keyboardType,
      style: TextStyle(fontSize: 13, color: colors.textPrimary),
      decoration: InputDecoration(
        labelText: label, isDense: true, filled: true, fillColor: colors.field,
        contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        prefixIcon: icon != null ? Padding(padding: const EdgeInsets.only(left: 8, right: 4), child: Icon(icon, size: 18, color: colors.textTertiary)) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.border, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.primary, width: 1.5)),
        labelStyle: TextStyle(fontSize: 12, color: colors.textTertiary),
      ),
    );
  }

  Widget _senderToggle(AppThemeColors colors) {
    return GestureDetector(
      onTap: () { setState(() => _wplataGotowkowa = !_wplataGotowkowa); _saveSender(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _wplataGotowkowa ? colors.field : colors.primary.withValues(alpha: .15),
          borderRadius: BorderRadius.circular(20),
          border: _wplataGotowkowa ? Border.all(color: colors.border.withValues(alpha: .3)) : Border.all(color: colors.primary.withValues(alpha: .3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_wplataGotowkowa ? Icons.money : Icons.account_balance, size: 14, color: _wplataGotowkowa ? colors.textTertiary : colors.primarySoft),
          const SizedBox(width: 4), Text(_wplataGotowkowa ? 'Gotówka' : 'Przelew', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _wplataGotowkowa ? colors.textTertiary : colors.primarySoft)),
        ]),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, AppThemeColors colors, VoidCallback? onTap) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: enabled ? colors.field : colors.backgroundTop, borderRadius: BorderRadius.circular(10), border: Border.all(color: colors.border.withValues(alpha: enabled ? .4 : .1))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: enabled ? colors.primarySoft : colors.textTertiary), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: enabled ? colors.textPrimary : colors.textTertiary))]),
      ),
    );
  }

  void _formatIban(String v) {
    final clean = v.replaceAll(RegExp(r'\s+'), '');
    if (clean.length == 26) {
      final fmt = IbanValidator.format(clean);
      if (fmt != v) {
        _kontoCtrl.value = TextEditingValue(text: fmt, selection: TextSelection.collapsed(offset: fmt.length));
        ref.read(transferFormProvider.notifier).updateKonto(fmt);
        return;
      }
    }
    ref.read(transferFormProvider.notifier).updateKonto(v);
  }

  void _clearAll() { _odbiorcaCtrl.clear(); _odbiorcaCdCtrl.clear(); _kontoCtrl.clear(); _walutaCtrl.clear(); _kwotaCtrl.clear(); _tytul1Ctrl.clear(); _tytul2Ctrl.clear(); setState(() => _odcinek = 'oba'); ref.read(transferFormProvider.notifier).reset(); }

  void _quickSavePayee() async {
    final name = _odbiorcaCtrl.text.trim();
    if (name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wpisz nazwę odbiorcy przed zapisem'), duration: Duration(seconds: 2)),
        );
      }
      return;
    }
    final alias = name.length > 20 ? name.substring(0, 20).toUpperCase() : name.toUpperCase();
    final payee = PayeeModel(alias: alias, odbiorca: name, odbiorcaCd: _odbiorcaCdCtrl.text.trim(), konto: _kontoCtrl.text.replaceAll(RegExp(r'\s+'), ''), kwota: _kwotaCtrl.text.trim(), tytul: _tytul1Ctrl.text.trim(), tytulCd: _tytul2Ctrl.text.trim());
    try {
      await ref.read(payeeStateProvider.notifier).save(payee);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Odbiorca "$alias" zapisany', style: const TextStyle(fontSize: 12)), duration: const Duration(seconds: 3)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd zapisu: $e'), backgroundColor: context.appColors.error, duration: const Duration(seconds: 4)));
      }
    }
  }

  void _validateAndProceed(BuildContext context, TransferFormState form, AppThemeColors colors) {
    final errors = <String>[];
    if (form.odbiorca.trim().isEmpty) errors.add('Brak nazwy odbiorcy');
    final kontoRaw = form.konto.replaceAll(RegExp(r'\s+'), '');
    if (kontoRaw.isEmpty) {
      errors.add('Brak numeru konta');
    } else {
      final clean = kontoRaw.startsWith('PL') ? kontoRaw.substring(2) : kontoRaw;
      final (valid, _) = IbanValidator.validate(kontoRaw);
      if (!valid) { errors.add('Niepoprawny numer konta (26 cyfr)'); } else if (!IbanValidator.checkMod97(clean)) { errors.add('Cyfra kontrolna IBAN jest niepoprawna'); }
    }
    final waluta = form.waluta.trim().toUpperCase();
    if (waluta.isEmpty || waluta.length != 3 || !RegExp(r'^[A-Z]{3}$').hasMatch(waluta)) {
      errors.add('Niepoprawna waluta (3 litery, np. PLN)');
    }
    final repo = ref.read(transferRepositoryProvider);
    final (kwotaOk, _) = repo.validateKwota(form.kwota);
    if (!kwotaOk) errors.add('Niepoprawna kwota (dodatnia liczba)');
    if (form.tytul1.trim().isEmpty && form.tytul2.trim().isEmpty) errors.add('Brak tytułu przelewu');
    if (errors.isNotEmpty) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errors.join('\n'), style: const TextStyle(fontSize: 12)), backgroundColor: colors.error, duration: const Duration(seconds: 4))); return; }
    HapticFeedback.mediumImpact();
    context.push('/preview');
  }
}
