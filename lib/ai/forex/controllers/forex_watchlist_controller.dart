import 'package:flutter/foundation.dart';

import '../models/forex_watchlist_item.dart';
import '../services/forex_watchlist_store.dart';

class ForexWatchlistController extends ChangeNotifier {
  final ForexWatchlistStore store;

  final List<ForexWatchlistItem> _items = <ForexWatchlistItem>[];
  bool _isLoading = false;
  bool _isSaving = false;
  Object? _lastError;

  ForexWatchlistController({
    ForexWatchlistStore? store,
  }) : store = store ?? ForexWatchlistStore();

  List<ForexWatchlistItem> get items =>
      List<ForexWatchlistItem>.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isBusy => _isLoading || _isSaving;
  Object? get lastError => _lastError;

  ForexWatchlistItem? get primaryItem {
    for (final ForexWatchlistItem item in _items) {
      if (item.isPrimary) {
        return item;
      }
    }
    return null;
  }

  ForexWatchlistItem? get primaryEnabledItem {
    for (final ForexWatchlistItem item in _items) {
      if (item.isPrimary && item.isEnabled) {
        return item;
      }
    }
    return null;
  }

  ForexWatchlistItem? get firstEnabledItem {
    for (final ForexWatchlistItem item in _items) {
      if (item.isEnabled) {
        return item;
      }
    }
    return null;
  }

  Future<void> load() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final List<ForexWatchlistItem> loaded = await store.loadItems();
      _items
        ..clear()
        ..addAll(_normalizePrimary(loaded));
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
      await store.saveItems(_items);
    } catch (error) {
      _lastError = error;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> add(ForexWatchlistItem item) async {
    final bool shouldBePrimary = _items.isEmpty || !_items.any((e) => e.isPrimary);
    _items.add(
      item.copyWith(isPrimary: shouldBePrimary ? true : item.isPrimary),
    );
    _ensureSinglePrimary();
    notifyListeners();
    await save();
  }

  Future<void> upsert(ForexWatchlistItem item) async {
    final int index = _items.indexWhere((ForexWatchlistItem e) => e.id == item.id);
    if (index == -1) {
      await add(item);
      return;
    }

    _items[index] = item;
    _ensureSinglePrimary();
    notifyListeners();
    await save();
  }

  Future<void> removeById(String id) async {
    _items.removeWhere((ForexWatchlistItem item) => item.id == id);
    _ensureSinglePrimary();
    notifyListeners();
    await save();
  }

  Future<void> setEnabled(String id, bool enabled) async {
    final int index = _items.indexWhere((ForexWatchlistItem item) => item.id == id);
    if (index == -1) {
      return;
    }

    _items[index] = _items[index].copyWith(isEnabled: enabled);
    notifyListeners();
    await save();
  }

  Future<void> setPrimary(String id) async {
    bool found = false;
    for (int i = 0; i < _items.length; i++) {
      final ForexWatchlistItem item = _items[i];
      final bool isPrimary = item.id == id;
      if (isPrimary) {
        found = true;
      }
      _items[i] = item.copyWith(isPrimary: isPrimary);
    }

    if (!found) {
      return;
    }

    notifyListeners();
    await save();
  }

  Future<void> clearAll({bool persist = true}) async {
    _items.clear();
    notifyListeners();
    if (!persist) {
      return;
    }
    await store.clear();
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  List<ForexWatchlistItem> _normalizePrimary(List<ForexWatchlistItem> items) {
    final List<ForexWatchlistItem> normalized = List<ForexWatchlistItem>.from(items);
    int primaryCount = 0;
    for (final ForexWatchlistItem item in normalized) {
      if (item.isPrimary) {
        primaryCount++;
      }
    }

    if (normalized.isEmpty) {
      return normalized;
    }

    if (primaryCount == 0) {
      normalized[0] = normalized[0].copyWith(isPrimary: true);
    } else if (primaryCount > 1) {
      bool kept = false;
      for (int i = 0; i < normalized.length; i++) {
        final ForexWatchlistItem item = normalized[i];
        if (item.isPrimary && !kept) {
          kept = true;
          continue;
        }
        if (item.isPrimary && kept) {
          normalized[i] = item.copyWith(isPrimary: false);
        }
      }
    }

    return normalized;
  }

  void _ensureSinglePrimary() {
    if (_items.isEmpty) {
      return;
    }

    int primaryIndex = _items.indexWhere((ForexWatchlistItem item) => item.isPrimary);
    if (primaryIndex == -1) {
      primaryIndex = 0;
      _items[0] = _items[0].copyWith(isPrimary: true);
    }

    for (int i = 0; i < _items.length; i++) {
      if (i == primaryIndex) {
        continue;
      }
      if (_items[i].isPrimary) {
        _items[i] = _items[i].copyWith(isPrimary: false);
      }
    }
  }
}
