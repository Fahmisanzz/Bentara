import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/app_settings_model.dart';
import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return SettingsRepository(localStorage);
});

class SettingsNotifier extends StateNotifier<AppSettingsModel> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const AppSettingsModel()) {
    _loadSettings();
  }

  void _loadSettings() {
    state = _repository.loadSettings();
  }

  Future<void> updateSettings(AppSettingsModel newSettings) async {
    state = newSettings;
    await _repository.saveSettings(newSettings);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettingsModel>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});
