import '../models/order_model.dart';

abstract class OrderRepository {
  Future<List<OrderModel>> getUserOrders(String userId);
  Future<void> placeOrder(OrderModel order);
}
