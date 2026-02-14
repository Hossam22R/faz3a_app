import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/exceptions.dart';
import '../../data_sources/remote/firebase_data_source.dart';
import '../payment_repository.dart';
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
      throw const AppException('Firebase is not initialized.');
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
