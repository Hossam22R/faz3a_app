import '../models/order_model.dart';

abstract class OrderRepository {
  Future<List<OrderModel>> getUserOrders(String userId);
  Future<List<OrderModel>> getVendorOrders(String vendorId);
  Future<List<OrderModel>> getAllOrders();
  Future<OrderModel?> getOrderById(String orderId);
  Future<void> placeOrder(OrderModel order);
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? cancelReason,
  });
}
