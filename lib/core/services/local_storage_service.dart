import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class ILocalStorageService {
  Future<void> init();
  Future<void> saveString(String key, String value);
  String? getString(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

class HiveLocalStorageService implements ILocalStorageService {
  static const String _boxName = 'bentara_box';
  late Box _box;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _box.put(key, value);
  }

  @override
  String? getString(String key) {
    return _box.get(key) as String?;
  }

  @override
  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}

final localStorageProvider = Provider<ILocalStorageService>((ref) {
  throw UnimplementedError('localStorageProvider must be overridden in main.dart');
});
