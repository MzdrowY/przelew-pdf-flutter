import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'payee_model.dart';

class PayeeRepository {
  Map<String, PayeeModel>? _cache;

  Future<String> get _filePath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/baza_adresowa.json';
  }

  Future<Map<String, PayeeModel>> loadAll() async {
    if (_cache != null) return Map.unmodifiable(_cache!);
    final path = await _filePath;
    final file = File(path);
    if (!await file.exists()) return const {};
    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    _cache = json.map((key, value) => MapEntry(
      key.toUpperCase(),
      PayeeModel.fromJson(key.toUpperCase(), value as Map<String, dynamic>),
    ));
    return Map.unmodifiable(_cache!);
  }

  Future<List<String>> getAllAliases() async {
    final data = await loadAll();
    return data.keys.toList()..sort();
  }

  Future<PayeeModel?> get(String alias) async {
    final data = await loadAll();
    return data[alias.toUpperCase()];
  }

  Future<void> save(PayeeModel payee) async {
    await loadAll();
    _cache![payee.alias.toUpperCase()] = payee;
    await _persist();
  }

  Future<void> delete(String alias) async {
    await loadAll();
    _cache!.remove(alias.toUpperCase());
    await _persist();
  }

  Future<void> _persist() async {
    final path = await _filePath;
    final json = _cache!.map((key, value) => MapEntry(key, value.toJson()));
    await File(path).writeAsString(jsonEncode(json));
  }
}
