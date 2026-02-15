import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/forex_watchlist_item.dart';

class ForexWatchlistStore {
  final String storageKey;
  final Future<SharedPreferences> _preferences;

  ForexWatchlistStore({
    SharedPreferences? sharedPreferences,
    this.storageKey = 'forex_watchlist_v1',
  }) : _preferences = sharedPreferences != null
            ? Future<SharedPreferences>.value(sharedPreferences)
            : SharedPreferences.getInstance();

  Future<List<ForexWatchlistItem>> loadItems() async {
    final SharedPreferences prefs = await _preferences;
    final String? raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const <ForexWatchlistItem>[];
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return const <ForexWatchlistItem>[];
    }

    if (decoded is! List) {
      return const <ForexWatchlistItem>[];
    }

    final List<ForexWatchlistItem> items = <ForexWatchlistItem>[];
    for (final dynamic item in decoded) {
      if (item is Map<String, dynamic>) {
        items.add(ForexWatchlistItem.fromJson(item));
      } else if (item is Map) {
        final Map<String, dynamic> converted = item.map(
          (dynamic key, dynamic value) =>
              MapEntry<String, dynamic>(key.toString(), value),
        );
        items.add(ForexWatchlistItem.fromJson(converted));
      }
    }

    return items.where((ForexWatchlistItem item) => item.id.isNotEmpty).toList();
  }

  Future<void> saveItems(List<ForexWatchlistItem> items) async {
    final SharedPreferences prefs = await _preferences;
    final String raw = jsonEncode(
      items.map((ForexWatchlistItem item) => item.toJson()).toList(),
    );
    await prefs.setString(storageKey, raw);
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await _preferences;
    await prefs.remove(storageKey);
  }
}
