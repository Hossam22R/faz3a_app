import '../models/order_model.dart';

abstract class OrderRepository {
  Future<List<OrderModel>> getUserOrders(String userId);
  Future<OrderModel?> getOrderById(String orderId);
  Future<void> placeOrder(OrderModel order);
}
