import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/iban_validator.dart';
import '../../../shared/widgets/accent_card.dart';
import '../../../shared/widgets/side_rail.dart';
import '../../payees/data/payee_model.dart';
import '../../payees/domain/payee_notifier.dart';
import '../../settings/domain/settings_notifier.dart';
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
  bool _senderInited = false;

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

  void _initSender(Map<String, dynamic> s) {
    if (_senderInited) return;
    _senderNazwaCtrl.text = s['nazwa'] as String? ?? '';
    _senderAdresCtrl.text = s['adres'] as String? ?? '';
    _senderKontoCtrl.text = s['konto_zleceniodawcy'] as String? ?? '';
    _wplataGotowkowa = s['wplata_gotowkowa'] as bool? ?? true;
    _senderInited = true;
  }

  void _saveSender() {
    ref.read(settingsStateProvider.notifier).update({
      'nazwa': _senderNazwaCtrl.text, 'adres': _senderAdresCtrl.text,
      'konto_zleceniodawcy': _senderKontoCtrl.text, 'wplata_gotowkowa': _wplataGotowkowa,
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsStateProvider);
    final history = ref.watch(historyListProvider);
    _initSender(settings);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A0A14), Color(0xFF12121E), Color(0xFF0A0A14)],
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 8),
                  _buildSenderSection(),
                  const SizedBox(height: 12),
                  _buildPayeeSection(),
                  const SizedBox(height: 12),
                  _buildDetailsSection(),
                  const SizedBox(height: 12),
                  const CalibrationSection(),
                  const SizedBox(height: 12),
                  _buildOptionsSection(),
                  const SizedBox(height: 16),
                  _buildGenerateButton(),
                  if (history.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildHistorySection(history),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: .5)),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7C75FF), Color(0xFF5A54CC)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.account_balance, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Text('Polecenie przelewu PDF', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -.3,
          )),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSenderSection() {
    return AccentCard(
      accentColor: const Color(0xFF4ECDC4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.person_outline, 'Zleceniodawca', _senderToggle()),
        const SizedBox(height: 12),
        _field(Icons.account_circle_outlined, 'Nazwa', _senderNazwaCtrl, onChanged: (_) => _saveSender()),
        const SizedBox(height: 8),
        _field(Icons.location_on_outlined, 'Adres', _senderAdresCtrl, maxLines: 2, onChanged: (_) => _saveSender()),
        if (!_wplataGotowkowa) ...[const SizedBox(height: 8), _field(Icons.account_balance_outlined, 'Nr konta', _senderKontoCtrl, onChanged: (_) => _saveSender())],
      ]),
    );
  }

  Widget _buildPayeeSection() {
    final payees = ref.watch(payeeStateProvider);
    final aliases = payees.keys.toList()..sort();
    return AccentCard(
      accentColor: const Color(0xFF7C75FF),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.people_alt_outlined, 'Odbiorca', TextButton(onPressed: () => context.push('/payees'), child: const Text('Edytuj', style: TextStyle(fontSize: 11)))),
        const SizedBox(height: 12),
        if (aliases.isNotEmpty)
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Wybierz z bazy', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
            dropdownColor: const Color(0xFF1C1C2A), isDense: true,
            items: aliases.map((a) => DropdownMenuItem(value: a, child: Text(a, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)))).toList(),
            onChanged: (alias) {
              if (alias == null) return; final p = payees[alias]; if (p == null) return;
              _odbiorcaCtrl.text = p.odbiorca; _odbiorcaCdCtrl.text = p.odbiorcaCd; _kontoCtrl.text = p.konto;
              _kwotaCtrl.text = p.kwota; _tytul1Ctrl.text = p.tytul; _tytul2Ctrl.text = p.tytulCd;
            },
          )
        else Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('Brak odbiorców — dodaj poniżej', style: Theme.of(context).textTheme.bodyMedium)),
      ]),
    );
  }

  Widget _buildDetailsSection() {
    return AccentCard(
      accentColor: const Color(0xFFFFA07A),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.receipt_long_outlined, 'Szczegóły przelewu', TextButton(onPressed: _clearAll, child: const Text('Wyczyść', style: TextStyle(fontSize: 11)))),
        const SizedBox(height: 12),
        _field(Icons.person_outline, 'Odbiorca (linia 1)', _odbiorcaCtrl),
        const SizedBox(height: 8),
        _field(null, 'Odbiorca (linia 2)', _odbiorcaCdCtrl),
        const SizedBox(height: 8),
        _field(Icons.credit_card_outlined, 'Nr konta', _kontoCtrl, onChanged: _formatIban),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(flex: 1, child: _field(Icons.currency_exchange_outlined, 'Waluta', _walutaCtrl)),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: _field(Icons.payments_outlined, 'Kwota', _kwotaCtrl)),
        ]),
        const SizedBox(height: 8),
        _field(Icons.subject_outlined, 'Tytułem (linia 1)', _tytul1Ctrl),
        const SizedBox(height: 8),
        _field(null, 'Tytułem (linia 2)', _tytul2Ctrl),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _actionBtn(Icons.bookmark_outline, 'Zapisz odbiorcę', _odbiorcaCtrl.text.trim().isNotEmpty ? _quickSavePayee : null)),
          const SizedBox(width: 8),
          Expanded(child: _actionBtn(Icons.preview_outlined, 'Podgląd', () => _validateAndProceed(context, ref.read(transferFormProvider)))),
        ]),
      ]),
    );
  }

  Widget _buildOptionsSection() {
    return AccentCard(
      accentColor: const Color(0xFF9D97FF),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.print_outlined, 'Opcje wydruku'),
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
                  color: sel ? AppColors.primary.withValues(alpha: .12) : const Color(0xFF151522),
                  borderRadius: BorderRadius.circular(10),
                  border: sel ? Border.all(color: AppColors.primary.withValues(alpha: .4)) : Border.all(color: AppColors.border.withValues(alpha: .3)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(sel ? Icons.check_circle : Icons.radio_button_unchecked, size: 14, color: sel ? AppColors.primarySoft : AppColors.textTertiary),
                  const SizedBox(width: 4), Text(e.value, style: TextStyle(fontSize: 11, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? AppColors.primarySoft : AppColors.textSecondary)),
                ]),
              ),
            ),
          );
        }).toList()),
      ]),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(colors: [Color(0xFF7C75FF), Color(0xFF6C63FF)]),
        boxShadow: [BoxShadow(color: const Color(0xFF7C75FF).withValues(alpha: .30), blurRadius: 24, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _validateAndProceed(context, ref.read(transferFormProvider)),
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

  Widget _buildHistorySection(List<Map<String, String>> history) {
    return AccentCard(
      accentColor: const Color(0xFF34B78F),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.access_time, 'Ostatnie przelewy'),
        const SizedBox(height: 12),
        ...history.take(5).map((e) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF181828), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border.withValues(alpha: .2))),
          child: Row(children: [
            SizedBox(width: 70, child: Text(e['data'] ?? '', style: TextStyle(fontSize: 11, color: AppColors.textTertiary))),
            Expanded(child: Text(e['odbiorca'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis, maxLines: 1)),
            Text(e['kwota'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF34B78F))),
          ]),
        )),
      ]),
    );
  }

  // ---------- HELPERS ----------
  Widget _sectionHeader(IconData icon, String label, [Widget? trailing]) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: AppColors.primarySoft)),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      if (trailing != null) ...[const Spacer(), trailing],
    ]);
  }

  Widget _field(IconData? icon, String label, TextEditingController ctrl, {int maxLines = 1, void Function(String)? onChanged, TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl, maxLines: maxLines, onChanged: onChanged, keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label, isDense: true, filled: true, fillColor: const Color(0xFF13131F),
        contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        prefixIcon: icon != null ? Padding(padding: const EdgeInsets.only(left: 8, right: 4), child: Icon(icon, size: 18, color: AppColors.textTertiary)) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2A2A3E), width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF7C75FF), width: 1.5)),
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
      ),
    );
  }

  Widget _senderToggle() {
    return GestureDetector(
      onTap: () { setState(() => _wplataGotowkowa = !_wplataGotowkowa); _saveSender(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _wplataGotowkowa ? const Color(0xFF151522) : AppColors.primary.withValues(alpha: .15),
          borderRadius: BorderRadius.circular(20),
          border: _wplataGotowkowa ? Border.all(color: AppColors.border.withValues(alpha: .3)) : Border.all(color: AppColors.primary.withValues(alpha: .3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_wplataGotowkowa ? Icons.money : Icons.account_balance, size: 14, color: _wplataGotowkowa ? AppColors.textTertiary : AppColors.primarySoft),
          const SizedBox(width: 4), Text(_wplataGotowkowa ? 'Gotówka' : 'Przelew', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _wplataGotowkowa ? AppColors.textTertiary : AppColors.primarySoft)),
        ]),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback? onTap) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: enabled ? const Color(0xFF151522) : const Color(0xFF0F0F1A), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border.withValues(alpha: enabled ? .4 : .1))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: enabled ? AppColors.primarySoft : AppColors.textTertiary), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: enabled ? AppColors.textPrimary : AppColors.textTertiary))]),
      ),
    );
  }

  void _formatIban(String v) {
    final clean = v.replaceAll(RegExp(r'\s+'), '');
    if (clean.length == 26) {
      final fmt = IbanValidator.format(clean);
      if (fmt != v) _kontoCtrl.value = TextEditingValue(text: fmt, selection: TextSelection.collapsed(offset: fmt.length));
    }
  }

  void _clearAll() { _odbiorcaCtrl.clear(); _odbiorcaCdCtrl.clear(); _kontoCtrl.clear(); _walutaCtrl.text = 'PLN'; _kwotaCtrl.clear(); _tytul1Ctrl.clear(); _tytul2Ctrl.clear(); ref.read(transferFormProvider.notifier).reset(); }

  void _quickSavePayee() {
    final name = _odbiorcaCtrl.text.trim();
    if (name.isEmpty) return;
    final alias = name.length > 20 ? name.substring(0, 20).toUpperCase() : name.toUpperCase();
    final payee = PayeeModel(alias: alias, odbiorca: name, odbiorcaCd: _odbiorcaCdCtrl.text.trim(), konto: _kontoCtrl.text.replaceAll(RegExp(r'\s+'), ''), kwota: _kwotaCtrl.text.trim(), tytul: _tytul1Ctrl.text.trim(), tytulCd: _tytul2Ctrl.text.trim());
    ref.read(payeeStateProvider.notifier).save(payee);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Odbiorca "$alias" zapisany', style: const TextStyle(fontSize: 12)), duration: const Duration(seconds: 2)));
  }

  void _validateAndProceed(BuildContext context, TransferFormState form) {
    final errors = <String>[];
    if (form.odbiorca.trim().isEmpty) errors.add('Brak nazwy odbiorcy');
    final kontoRaw = form.konto.replaceAll(RegExp(r'\s+'), '');
    if (kontoRaw.isNotEmpty) {
      final clean = kontoRaw.startsWith('PL') ? kontoRaw.substring(2) : kontoRaw;
      final (valid, _) = IbanValidator.validate(kontoRaw);
      if (!valid) { errors.add('Niepoprawny numer konta (26 cyfr)'); } else if (!IbanValidator.checkMod97(clean)) { errors.add('Cyfra kontrolna IBAN jest niepoprawna'); }
    }
    if (form.tytul1.trim().isEmpty && form.tytul2.trim().isEmpty) errors.add('Brak tytułu przelewu');
    if (errors.isNotEmpty) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errors.join('\n'), style: const TextStyle(fontSize: 12)), backgroundColor: AppColors.error, duration: const Duration(seconds: 4))); return; }
    HapticFeedback.mediumImpact();
    context.push('/preview');
  }
}
