import 'package:flutter/foundation.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._orderRepository);

  final OrderRepository _orderRepository;

  List<OrderModel> _orders = <OrderModel>[];
  OrderModel? _selectedOrder;
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
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
}
