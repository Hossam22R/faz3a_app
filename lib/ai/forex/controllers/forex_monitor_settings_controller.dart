import 'package:flutter/foundation.dart';

import '../models/forex_monitor_settings.dart';
import '../services/forex_monitor_settings_store.dart';

class ForexMonitorSettingsController extends ChangeNotifier {
  final ForexMonitorSettingsStore store;

  ForexMonitorSettings _settings = const ForexMonitorSettings.defaults();
  bool _isLoading = false;
  bool _isSaving = false;
  Object? _lastError;

  ForexMonitorSettingsController({
    ForexMonitorSettingsStore? store,
  }) : store = store ?? ForexMonitorSettingsStore();

  ForexMonitorSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  Object? get lastError => _lastError;

  Future<void> load() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _settings = await store.load();
    } catch (error) {
      _lastError = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> save() async {
    _isSaving = true;
    _lastError = null;
    notifyListeners();

    try {
      await store.save(_settings);
    } catch (error) {
      _lastError = error;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> saveSettings(ForexMonitorSettings settings) async {
    _settings = settings;
    notifyListeners();
    await save();
  }

  void update(ForexMonitorSettings settings) {
    _settings = settings;
    notifyListeners();
  }

  Future<void> resetToDefaults({bool persist = false}) async {
    _settings = const ForexMonitorSettings.defaults();
    notifyListeners();

    if (persist) {
      await save();
    }
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}
