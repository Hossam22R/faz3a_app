import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/exceptions.dart';
import '../../data_sources/remote/firebase_data_source.dart';
import '../../models/order_model.dart';
import '../order_repository.dart';
import 'firebase_repository_utils.dart';

class FirebaseOrderRepository implements OrderRepository {
  FirebaseOrderRepository(this._dataSource);

  final FirebaseDataSource _dataSource;

  @override
  Future<List<OrderModel>> getUserOrders(String userId) async {
    if (!isFirebaseReady) {
      return const <OrderModel>[];
    }
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _dataSource
        .ordersCollection()
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    return snapshot.docs
        .map(
          (doc) => OrderModel.fromJson(<String, dynamic>{
            ...doc.data(),
            'id': doc.data()['id'] ?? doc.id,
          }),
        )
        .toList();
  }

  @override
  Future<List<OrderModel>> getVendorOrders(String vendorId) async {
    if (!isFirebaseReady) {
      return const <OrderModel>[];
    }
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _dataSource.ordersCollection().limit(250).get();

    final List<OrderModel> orders = snapshot.docs
        .map(
          (doc) => OrderModel.fromJson(<String, dynamic>{
            ...doc.data(),
            'id': doc.data()['id'] ?? doc.id,
          }),
        )
        .where((OrderModel order) => order.vendorId == vendorId || order.vendorId == 'multi-vendor')
        .toList();
    orders.sort((OrderModel a, OrderModel b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    if (!isFirebaseReady) {
      return const <OrderModel>[];
    }
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _dataSource
        .ordersCollection()
        .orderBy('createdAt', descending: true)
        .limit(300)
        .get();

    return snapshot.docs
        .map(
          (doc) => OrderModel.fromJson(<String, dynamic>{
            ...doc.data(),
            'id': doc.data()['id'] ?? doc.id,
          }),
        )
        .toList();
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    if (!isFirebaseReady) {
      return null;
    }
    final doc = await _dataSource.ordersCollection().doc(orderId).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return OrderModel.fromJson(<String, dynamic>{
      ...doc.data()!,
      'id': doc.data()!['id'] ?? doc.id,
    });
  }

  @override
  Future<void> placeOrder(OrderModel order) async {
    if (!isFirebaseReady) {
      throw const AppException('Firebase is not initialized.');
    }
    await _dataSource.ordersCollection().doc(order.id).set(order.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? cancelReason,
  }) async {
    if (!isFirebaseReady) {
      throw const AppException('Firebase is not initialized.');
    }

    final Map<String, dynamic> payload = <String, dynamic>{
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (status == OrderStatus.cancelled) {
      payload['cancelReason'] = cancelReason ?? 'Cancelled by operator';
    } else {
      payload['cancelReason'] = null;
    }
    if (status == OrderStatus.delivered) {
      payload['deliveredAt'] = FieldValue.serverTimestamp();
    }

    await _dataSource.ordersCollection().doc(orderId).set(payload, SetOptions(merge: true));
  }
}
