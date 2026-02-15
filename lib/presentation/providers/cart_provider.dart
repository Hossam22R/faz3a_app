import 'package:flutter/foundation.dart';

import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._cartRepository);

  final CartRepository _cartRepository;

  List<CartItemModel> _items = <CartItemModel>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalItems => _items.fold<int>(0, (int sum, CartItemModel item) => sum + item.quantity);
  double get subtotal => _items.fold<double>(0, (double sum, CartItemModel item) => sum + item.totalPrice);

  Future<void> loadCart(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _cartRepository.getUserCart(userId);
    } catch (error) {
      _errorMessage = error.toString();
      _items = <CartItemModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct({
    required String userId,
    required ProductModel product,
    int quantity = 1,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final int existingIndex = _items.indexWhere((CartItemModel item) => item.productId == product.id);
      if (existingIndex >= 0) {
        final CartItemModel existing = _items[existingIndex];
        final CartItemModel updated = existing.copyWith(
          quantity: existing.quantity + quantity,
          updatedAt: DateTime.now(),
        );
        await _cartRepository.addToCart(updated);
        _items[existingIndex] = updated;
      } else {
        final CartItemModel newItem = CartItemModel(
          id: '${userId}_${product.id}',
          userId: userId,
          productId: product.id,
          productName: product.name,
          productImage: product.images.isNotEmpty ? product.images.first : null,
          unitPrice: product.finalPrice,
          quantity: quantity,
          maxQuantity: product.stock,
          createdAt: DateTime.now(),
        );
        await _cartRepository.addToCart(newItem);
        _items = <CartItemModel>[..._items, newItem];
      }
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity({
    required String userId,
    required String itemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      await removeItem(userId: userId, itemId: itemId);
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final int index = _items.indexWhere((CartItemModel item) => item.id == itemId);
      if (index < 0) {
        _errorMessage = 'Cart item not found.';
        return;
      }
      final CartItemModel updated = _items[index].copyWith(
        quantity: quantity,
        updatedAt: DateTime.now(),
      );
      await _cartRepository.addToCart(updated);
      _items[index] = updated;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeItem({
    required String userId,
    required String itemId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _cartRepository.removeFromCart(userId: userId, itemId: itemId);
      _items = _items.where((CartItemModel item) => item.id != itemId).toList();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _cartRepository.clearCart(userId);
      _items = <CartItemModel>[];
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearLocalOnly() {
    _items = <CartItemModel>[];
    notifyListeners();
  }
}
