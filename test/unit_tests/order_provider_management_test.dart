import 'package:flutter_test/flutter_test.dart';
import 'package:nema_store/data/models/cart_item_model.dart';
import 'package:nema_store/data/models/order_model.dart';
import 'package:nema_store/data/repositories/order_repository.dart';
import 'package:nema_store/presentation/providers/order_provider.dart';

class _FakeOrderRepository implements OrderRepository {
  final Map<String, OrderModel> _ordersById = <String, OrderModel>{};

  void seed(OrderModel order) {
    _ordersById[order.id] = order;
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    return _ordersById.values.toList();
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    return _ordersById[orderId];
  }

  @override
  Future<List<OrderModel>> getUserOrders(String userId) async {
    return _ordersById.values.where((OrderModel order) => order.userId == userId).toList();
  }

  @override
  Future<List<OrderModel>> getVendorOrders(String vendorId) async {
    return _ordersById.values.where((OrderModel order) => order.vendorId == vendorId).toList();
  }

  @override
  Future<void> placeOrder(OrderModel order) async {
    _ordersById[order.id] = order;
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? cancelReason,
  }) async {
    final OrderModel? order = _ordersById[orderId];
    if (order == null) {
      return;
    }
    _ordersById[orderId] = order.copyWith(
      status: status,
      cancelReason: status == OrderStatus.cancelled ? cancelReason : null,
      updatedAt: DateTime.now(),
    );
  }
}

void main() {
  group('OrderProvider management flows', () {
    test('loads vendor orders and updates status', () async {
      final _FakeOrderRepository repository = _FakeOrderRepository();
      final OrderModel order = OrderModel(
        id: 'o1',
        orderNumber: 'NS-1',
        userId: 'u1',
        vendorId: 'v1',
        items: const <CartItemModel>[],
        subtotal: 10000,
        total: 10000,
        createdAt: DateTime.now(),
      );
      repository.seed(order);

      final OrderProvider provider = OrderProvider(repository);
      await provider.loadVendorOrders('v1');
      await provider.loadAllOrdersForManagement();
      await provider.loadOrderById('o1');

      expect(provider.vendorOrders, hasLength(1));
      expect(provider.managementOrders, hasLength(1));
      expect(provider.selectedOrder?.status, OrderStatus.pending);

      final bool updated = await provider.updateStatus(
        orderId: 'o1',
        status: OrderStatus.confirmed,
      );

      expect(updated, isTrue);
      expect(provider.vendorOrders.first.status, OrderStatus.confirmed);
      expect(provider.managementOrders.first.status, OrderStatus.confirmed);
      expect(provider.selectedOrder?.status, OrderStatus.confirmed);
    });
  });
}
