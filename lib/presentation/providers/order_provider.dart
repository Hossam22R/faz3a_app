import 'package:flutter/foundation.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._orderRepository);

  final OrderRepository _orderRepository;

  List<OrderModel> _orders = <OrderModel>[];
  List<OrderModel> _vendorOrders = <OrderModel>[];
  List<OrderModel> _managementOrders = <OrderModel>[];
  OrderModel? _selectedOrder;
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  List<OrderModel> get vendorOrders => _vendorOrders;
  List<OrderModel> get managementOrders => _managementOrders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrders(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _orders = await _orderRepository.getUserOrders(userId);
    } catch (error) {
      _errorMessage = error.toString();
      _orders = <OrderModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrderById(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedOrder = null;
    notifyListeners();
    try {
      _selectedOrder = await _orderRepository.getOrderById(orderId);
      if (_selectedOrder == null) {
        _errorMessage = 'Order not found.';
      }
    } catch (error) {
      _errorMessage = error.toString();
      _selectedOrder = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVendorOrders(String vendorId) async {
    _isLoading = true;
    _errorMessage = null;
    _vendorOrders = <OrderModel>[];
    notifyListeners();
    try {
      _vendorOrders = await _orderRepository.getVendorOrders(vendorId);
    } catch (error) {
      _errorMessage = error.toString();
      _vendorOrders = <OrderModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllOrdersForManagement() async {
    _isLoading = true;
    _errorMessage = null;
    _managementOrders = <OrderModel>[];
    notifyListeners();
    try {
      _managementOrders = await _orderRepository.getAllOrders();
    } catch (error) {
      _errorMessage = error.toString();
      _managementOrders = <OrderModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> placeOrder(OrderModel order) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _orderRepository.placeOrder(order);
      _selectedOrder = order;
      _orders = <OrderModel>[
        order,
        ..._orders.where((OrderModel item) => item.id != order.id),
      ];
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus({
    required String orderId,
    required OrderStatus status,
    String? cancelReason,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _orderRepository.updateOrderStatus(
        orderId: orderId,
        status: status,
        cancelReason: cancelReason,
      );
      final DateTime now = DateTime.now();
      _orders = _applyStatus(_orders, orderId, status, cancelReason, now);
      _vendorOrders = _applyStatus(_vendorOrders, orderId, status, cancelReason, now);
      _managementOrders = _applyStatus(_managementOrders, orderId, status, cancelReason, now);
      if (_selectedOrder?.id == orderId) {
        _selectedOrder = _selectedOrder!.copyWith(
          status: status,
          cancelReason: status == OrderStatus.cancelled ? (cancelReason ?? _selectedOrder!.cancelReason) : null,
          updatedAt: now,
          deliveredAt: status == OrderStatus.delivered ? now : _selectedOrder!.deliveredAt,
        );
      }
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<OrderModel> _applyStatus(
    List<OrderModel> source,
    String orderId,
    OrderStatus status,
    String? cancelReason,
    DateTime updatedAt,
  ) {
    return source.map((OrderModel order) {
      if (order.id != orderId) {
        return order;
      }
      return order.copyWith(
        status: status,
        cancelReason: status == OrderStatus.cancelled ? (cancelReason ?? order.cancelReason) : null,
        updatedAt: updatedAt,
        deliveredAt: status == OrderStatus.delivered ? updatedAt : order.deliveredAt,
      );
    }).toList();
  }
}
