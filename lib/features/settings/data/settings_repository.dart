import 'dart:convert';
import '../../../core/services/local_storage_service.dart';
import '../models/app_settings_model.dart';

class SettingsRepository {
  final ILocalStorageService _localStorage;
  static const String _settingsKey = 'app_settings';

  SettingsRepository(this._localStorage);

  Future<void> saveSettings(AppSettingsModel settings) async {
    final jsonStr = jsonEncode(settings.toJson());
    await _localStorage.saveString(_settingsKey, jsonStr);
  }

  AppSettingsModel loadSettings() {
    final jsonStr = _localStorage.getString(_settingsKey);
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr);
        return AppSettingsModel.fromJson(map);
      } catch (_) {}
    }
    return const AppSettingsModel();
  }
}
