import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/payee_model.dart';
import '../data/payee_repository.dart';

final payeeRepositoryProvider = Provider<PayeeRepository>((ref) {
  return PayeeRepository();
});

final payeeListProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.read(payeeRepositoryProvider);
  return repo.getAllAliases();
});

final payeeProvider = FutureProvider.family<PayeeModel?, String>((ref, alias) async {
  final repo = ref.read(payeeRepositoryProvider);
  return repo.get(alias);
});

class PayeeNotifier extends StateNotifier<Map<String, PayeeModel>> {
  final PayeeRepository _repo;

  PayeeNotifier(this._repo) : super({});

  Future<void> loadAll() async {
    state = await _repo.loadAll();
  }

  Future<void> save(PayeeModel payee) async {
    await _repo.save(payee);
    await loadAll();
  }

  Future<void> delete(String alias) async {
    await _repo.delete(alias);
    await loadAll();
  }

  List<String> get aliases => state.keys.toList()..sort();
}

final payeeStateProvider =
    StateNotifierProvider<PayeeNotifier, Map<String, PayeeModel>>((ref) {
  final repo = ref.read(payeeRepositoryProvider);
  final notifier = PayeeNotifier(repo);
  notifier.loadAll();
  return notifier;
});
