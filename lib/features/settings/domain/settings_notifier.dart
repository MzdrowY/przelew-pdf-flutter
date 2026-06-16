import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.read(settingsRepositoryProvider);
  return repo.load();
});

class SettingsNotifier extends StateNotifier<Map<String, dynamic>> {
  final SettingsRepository _repo;
  final Ref _ref;

  SettingsNotifier(this._repo, this._ref) : super({});

  Future<void> load() async {
    state = await _repo.load();
  }

  Future<void> update(Map<String, dynamic> updates) async {
    final merged = {...state, ...updates};
    await _repo.save(merged);
    state = merged;
  }

  Future<void> addHistoryEntry(Map<String, String> entry) async {
    await _repo.addHistoryEntry(entry);
    _ref.invalidate(historyListProvider);
  }

  List<Map<String, String>> getHistory() => _repo.getHistory();
}

final settingsStateProvider = StateNotifierProvider<SettingsNotifier, Map<String, dynamic>>((ref) {
  final repo = ref.read(settingsRepositoryProvider);
  final notifier = SettingsNotifier(repo, ref);
  notifier.load();
  return notifier;
});

final historyListProvider = Provider<List<Map<String, String>>>((ref) {
  final repo = ref.read(settingsRepositoryProvider);
  return repo.getHistory();
});
