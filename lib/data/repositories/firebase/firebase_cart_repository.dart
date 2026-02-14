import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/exceptions.dart';
import '../../data_sources/remote/firebase_data_source.dart';
import '../../models/cart_item_model.dart';
import '../cart_repository.dart';
import 'firebase_repository_utils.dart';

class FirebaseCartRepository implements CartRepository {
  FirebaseCartRepository(this._dataSource);

  final FirebaseDataSource _dataSource;

  @override
  Future<List<CartItemModel>> getUserCart(String userId) async {
    if (!isFirebaseReady) {
      return const <CartItemModel>[];
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _dataSource.cartItemsCollection(userId).orderBy('createdAt', descending: true).get();

    return snapshot.docs
        .map(
          (doc) => CartItemModel.fromJson(<String, dynamic>{
            ...doc.data(),
            'id': doc.data()['id'] ?? doc.id,
            'userId': doc.data()['userId'] ?? userId,
          }),
        )
        .toList();
  }

  @override
  Future<void> addToCart(CartItemModel item) async {
    if (!isFirebaseReady) {
      throw const AppException('Firebase is not initialized.');
    }

    await _dataSource
        .cartItemsCollection(item.userId)
        .doc(item.id)
        .set(item.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> removeFromCart({
    required String userId,
    required String itemId,
  }) async {
    if (!isFirebaseReady) {
      throw const AppException('Firebase is not initialized.');
    }
    await _dataSource.cartItemsCollection(userId).doc(itemId).delete();
  }

  @override
  Future<void> clearCart(String userId) async {
    if (!isFirebaseReady) {
      throw const AppException('Firebase is not initialized.');
    }

    final snapshot = await _dataSource.cartItemsCollection(userId).get();
    final WriteBatch batch = _dataSource.firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
