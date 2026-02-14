import 'package:flutter_test/flutter_test.dart';
import 'package:nema_store/data/models/cart_item_model.dart';
import 'package:nema_store/data/models/product_model.dart';
import 'package:nema_store/data/repositories/cart_repository.dart';
import 'package:nema_store/presentation/providers/cart_provider.dart';

class _FakeCartRepository implements CartRepository {
  final Map<String, CartItemModel> _itemsById = <String, CartItemModel>{};

  @override
  Future<void> addToCart(CartItemModel item) async {
    _itemsById[item.id] = item;
  }

  @override
  Future<void> clearCart(String userId) async {
    _itemsById.removeWhere((_, CartItemModel item) => item.userId == userId);
  }

  @override
  Future<List<CartItemModel>> getUserCart(String userId) async {
    return _itemsById.values.where((CartItemModel item) => item.userId == userId).toList();
  }

  @override
  Future<void> removeFromCart({
    required String userId,
    required String itemId,
  }) async {
    _itemsById.remove(itemId);
  }
}

void main() {
  group('CartProvider', () {
    test('adds same product by increasing quantity', () async {
      final _FakeCartRepository repository = _FakeCartRepository();
      final CartProvider provider = CartProvider(repository);
      final ProductModel product = ProductModel(
        id: 'p1',
        vendorId: 'v1',
        name: 'Test Product',
        description: 'Desc',
        categoryId: 'c1',
        price: 10000,
        stock: 10,
        images: const <String>[],
        createdAt: DateTime.now(),
      );

      await provider.addProduct(userId: 'u1', product: product, quantity: 1);
      await provider.addProduct(userId: 'u1', product: product, quantity: 2);

      expect(provider.items, hasLength(1));
      expect(provider.items.first.quantity, 3);
      expect(provider.totalItems, 3);
      expect(provider.subtotal, 30000);
    });

    test('updateQuantity removes when set to zero', () async {
      final _FakeCartRepository repository = _FakeCartRepository();
      final CartProvider provider = CartProvider(repository);
      final ProductModel product = ProductModel(
        id: 'p2',
        vendorId: 'v1',
        name: 'Another',
        description: 'Desc',
        categoryId: 'c1',
        price: 5000,
        stock: 5,
        images: const <String>[],
        createdAt: DateTime.now(),
      );

      await provider.addProduct(userId: 'u1', product: product, quantity: 1);
      final String itemId = provider.items.first.id;
      await provider.updateQuantity(userId: 'u1', itemId: itemId, quantity: 0);

      expect(provider.items, isEmpty);
      expect(provider.totalItems, 0);
    });
  });
}
