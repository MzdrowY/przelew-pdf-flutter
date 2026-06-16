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
    if (_cache != null) return _cache!;
    final path = await _filePath;
    final file = File(path);
    if (!await file.exists()) return {};
    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    _cache = json.map((key, value) => MapEntry(
      key.toUpperCase(),
      PayeeModel.fromJson(key.toUpperCase(), value as Map<String, dynamic>),
    ));
    return _cache!;
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
    final data = await loadAll();
    data[payee.alias.toUpperCase()] = payee;
    await _persist(data);
  }

  Future<void> delete(String alias) async {
    final data = await loadAll();
    data.remove(alias.toUpperCase());
    await _persist(data);
  }

  Future<void> _persist(Map<String, PayeeModel> data) async {
    _cache = data;
    final path = await _filePath;
    final json = data.map((key, value) => MapEntry(key, value.toJson()));
    await File(path).writeAsString(jsonEncode(json));
  }
}
