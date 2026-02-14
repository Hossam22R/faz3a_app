import 'package:flutter/foundation.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, int> _items = <String, int>{};

  Map<String, int> get items => Map<String, int>.unmodifiable(_items);

  int get totalItems => _items.values.fold<int>(0, (int sum, int qty) => sum + qty);

  void addItem(String productId, {int quantity = 1}) {
    _items.update(productId, (int current) => current + quantity, ifAbsent: () => quantity);
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
