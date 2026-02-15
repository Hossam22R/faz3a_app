import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/forex_monitor_settings.dart';

class ForexMonitorSettingsStore {
  final String storageKey;
  final Future<SharedPreferences> _preferences;

  ForexMonitorSettingsStore({
    SharedPreferences? sharedPreferences,
    this.storageKey = 'forex_monitor_settings_v1',
  }) : _preferences = sharedPreferences != null
            ? Future<SharedPreferences>.value(sharedPreferences)
            : SharedPreferences.getInstance();

  Future<ForexMonitorSettings> load() async {
    final SharedPreferences prefs = await _preferences;
    final String? raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const ForexMonitorSettings.defaults();
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return const ForexMonitorSettings.defaults();
    }

    if (decoded is! Map<String, dynamic>) {
      if (decoded is Map) {
        final Map<String, dynamic> converted = decoded.map(
          (dynamic key, dynamic value) =>
              MapEntry<String, dynamic>(key.toString(), value),
        );
        return ForexMonitorSettings.fromJson(converted);
      }
      return const ForexMonitorSettings.defaults();
    }

    return ForexMonitorSettings.fromJson(decoded);
  }

  Future<void> save(ForexMonitorSettings settings) async {
    final SharedPreferences prefs = await _preferences;
    final String raw = jsonEncode(settings.toJson());
    await prefs.setString(storageKey, raw);
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await _preferences;
    await prefs.remove(storageKey);
  }
}
