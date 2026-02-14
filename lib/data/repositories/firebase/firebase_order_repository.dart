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
  Future<void> placeOrder(OrderModel order) async {
    if (!isFirebaseReady) {
      throw const AppException('Firebase is not initialized.');
    }
    await _dataSource.ordersCollection().doc(order.id).set(order.toJson(), SetOptions(merge: true));
  }
}
