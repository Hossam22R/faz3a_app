import 'package:flutter_test/flutter_test.dart';
import 'package:nema_store/data/models/order_model.dart';

void main() {
  group('OrderModel', () {
    test('supports legacy payload with single product fields', () {
      final OrderModel order = OrderModel.fromJson(<String, dynamic>{
        'orderId': 'o1',
        'productId': 'p1',
        'quantity': 2,
        'price': 25000,
      });

      expect(order.id, 'o1');
      expect(order.items.length, 1);
      expect(order.totalItemsCount, 2);
      expect(order.subtotal, 50000);
    });
  });
}
