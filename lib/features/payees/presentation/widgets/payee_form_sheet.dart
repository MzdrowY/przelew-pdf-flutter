import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/utils/iban_validator.dart';
import '../../domain/payee_notifier.dart';
import '../../data/payee_model.dart';

class PayeeFormSheet extends ConsumerStatefulWidget {
  final PayeeModel? existing;

  const PayeeFormSheet({super.key, this.existing});

  @override
  ConsumerState<PayeeFormSheet> createState() => _PayeeFormSheetState();
}

class _PayeeFormSheetState extends ConsumerState<PayeeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _aliasCtrl;
  late final TextEditingController _odbiorcaCtrl;
  late final TextEditingController _odbiorcaCdCtrl;
  late final TextEditingController _kontoCtrl;
  late final TextEditingController _kwotaCtrl;
  late final TextEditingController _tytulCtrl;
  late final TextEditingController _tytulCdCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _aliasCtrl = TextEditingController(text: e?.alias ?? '');
    _odbiorcaCtrl = TextEditingController(text: e?.odbiorca ?? '');
    _odbiorcaCdCtrl = TextEditingController(text: e?.odbiorcaCd ?? '');
    _kontoCtrl = TextEditingController(text: e?.konto ?? '');
    _kwotaCtrl = TextEditingController(text: e?.kwota ?? '');
    _tytulCtrl = TextEditingController(text: e?.tytul ?? '');
    _tytulCdCtrl = TextEditingController(text: e?.tytulCd ?? '');
  }

  @override
  void dispose() {
    _aliasCtrl.dispose();
    _odbiorcaCtrl.dispose();
    _odbiorcaCdCtrl.dispose();
    _kontoCtrl.dispose();
    _kwotaCtrl.dispose();
    _tytulCtrl.dispose();
    _tytulCdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.existing != null ? 'Edytuj odbiorcę' : 'Dodaj odbiorcę',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Alias',
                controller: _aliasCtrl,
                validator: (v) => v == null || v.trim().isEmpty ? 'Alias jest wymagany' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(label: 'Nazwa odbiorcy (linia 1)', controller: _odbiorcaCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'Nazwa odbiorcy (linia 2)', controller: _odbiorcaCdCtrl),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Numer konta (26 cyfr)',
                controller: _kontoCtrl,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final (ok, _) = IbanValidator.validate(v);
                  return ok ? null : 'Nieprawidłowy numer konta';
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Kwota (np. 1250,00)',
                controller: _kwotaCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(label: 'Tytułem (linia 1)', controller: _tytulCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'Tytułem (linia 2)', controller: _tytulCdCtrl),
              const SizedBox(height: 24),
              AppButton(
                label: widget.existing != null ? 'Zapisz zmiany' : 'Dodaj odbiorcę',
                icon: Icons.save,
                onPressed: _save,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final kontoRaw = _kontoCtrl.text.replaceAll(RegExp(r'\s+'), '');
    if (kontoRaw.isNotEmpty) {
      final (valid, _) = IbanValidator.validate(kontoRaw);
      if (!valid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Niepoprawny numer konta')),
        );
        return;
      }
    }

    final payee = PayeeModel(
      alias: _aliasCtrl.text.trim().toUpperCase(),
      odbiorca: _odbiorcaCtrl.text.trim(),
      odbiorcaCd: _odbiorcaCdCtrl.text.trim(),
      konto: kontoRaw,
      kwota: _kwotaCtrl.text.trim(),
      tytul: _tytulCtrl.text.trim(),
      tytulCd: _tytulCdCtrl.text.trim(),
    );

    ref.read(payeeStateProvider.notifier).save(payee);
    Navigator.pop(context);
  }
}
