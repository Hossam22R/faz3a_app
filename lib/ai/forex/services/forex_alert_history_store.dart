import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/forex_signal_alert.dart';

class ForexAlertHistoryStore {
  final String storageKey;
  final Future<SharedPreferences> _preferences;

  ForexAlertHistoryStore({
    SharedPreferences? sharedPreferences,
    this.storageKey = 'forex_alert_history',
  }) : _preferences = sharedPreferences != null
            ? Future<SharedPreferences>.value(sharedPreferences)
            : SharedPreferences.getInstance();

  Future<List<ForexSignalAlert>> loadAlerts({int maxItems = 200}) async {
    final SharedPreferences prefs = await _preferences;
    final String? raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const <ForexSignalAlert>[];
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return const <ForexSignalAlert>[];
    }

    if (decoded is! List) {
      return const <ForexSignalAlert>[];
    }

    final List<ForexSignalAlert> alerts = <ForexSignalAlert>[];
    for (final dynamic item in decoded) {
      if (item is Map<String, dynamic>) {
        alerts.add(ForexSignalAlert.fromJson(item));
      } else if (item is Map) {
        alerts.add(
          ForexSignalAlert.fromJson(
            item.map(
              (dynamic key, dynamic value) =>
                  MapEntry<String, dynamic>(key.toString(), value),
            ),
          ),
        );
      }
    }

    alerts.sort((ForexSignalAlert a, ForexSignalAlert b) {
      return b.createdAt.compareTo(a.createdAt);
    });

    if (alerts.length <= maxItems) {
      return alerts;
    }

    return alerts.sublist(0, maxItems);
  }

  Future<void> saveAlerts(
    List<ForexSignalAlert> alerts, {
    int maxItems = 200,
  }) async {
    final SharedPreferences prefs = await _preferences;
    final List<ForexSignalAlert> trimmed =
        alerts.length <= maxItems ? alerts : alerts.sublist(0, maxItems);
    final String encoded = jsonEncode(
      trimmed.map((ForexSignalAlert alert) => alert.toJson()).toList(),
    );
    await prefs.setString(storageKey, encoded);
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await _preferences;
    await prefs.remove(storageKey);
  }
}
