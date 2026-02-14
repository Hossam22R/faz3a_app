import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data_sources/remote/firebase_data_source.dart';
import '../payment_repository.dart';
import 'firebase_demo_store.dart';
import 'firebase_repository_utils.dart';

class FirebasePaymentRepository implements PaymentRepository {
  FirebasePaymentRepository(this._dataSource);

  final FirebaseDataSource _dataSource;

  @override
  Future<bool> processPayment({
    required double amount,
    required PaymentMethod method,
    required String orderId,
  }) async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      final bool isImmediateSuccess = method == PaymentMethod.cashOnDelivery;
      FirebaseDemoStore.paymentByOrderId[orderId] = <String, dynamic>{
        'amount': amount,
        'method': method.name,
        'status': isImmediateSuccess ? 'pending_collection' : 'initiated',
        'updatedAt': DateTime.now().toIso8601String(),
      };
      return isImmediateSuccess;
    }

    final bool isImmediateSuccess = method == PaymentMethod.cashOnDelivery;
    await _dataSource.ordersCollection().doc(orderId).set(
      <String, dynamic>{
        'payment': <String, dynamic>{
          'amount': amount,
          'method': method.name,
          'status': isImmediateSuccess ? 'pending_collection' : 'initiated',
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      SetOptions(merge: true),
    );
    return isImmediateSuccess;
  }
}
