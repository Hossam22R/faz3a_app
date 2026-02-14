import '../models/cart_item_model.dart';

abstract class CartRepository {
  Future<List<CartItemModel>> getUserCart(String userId);
  Future<void> addToCart(CartItemModel item);
  Future<void> removeFromCart({
    required String userId,
    required String itemId,
  });
  Future<void> clearCart(String userId);
}
