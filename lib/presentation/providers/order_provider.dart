import 'package:flutter/foundation.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._orderRepository);

  final OrderRepository _orderRepository;

  List<OrderModel> _orders = <OrderModel>[];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadOrders(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _orderRepository.getUserOrders(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
