import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data_sources/remote/firebase_data_source.dart';
import '../../models/cart_item_model.dart';
import '../cart_repository.dart';
import 'firebase_demo_store.dart';
import 'firebase_repository_utils.dart';

class FirebaseCartRepository implements CartRepository {
  FirebaseCartRepository(this._dataSource);

  final FirebaseDataSource _dataSource;

  @override
  Future<List<CartItemModel>> getUserCart(String userId) async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      final List<CartItemModel> items = FirebaseDemoStore.cartItemsById.values
          .where((CartItemModel item) => item.userId == userId)
          .toList();
      items.sort((CartItemModel a, CartItemModel b) => b.createdAt.compareTo(a.createdAt));
      return items;
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
      FirebaseDemoStore.ensureInitialized();
      FirebaseDemoStore.cartItemsById[item.id] = item;
      return;
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
      FirebaseDemoStore.ensureInitialized();
      FirebaseDemoStore.cartItemsById.remove(itemId);
      return;
    }
    await _dataSource.cartItemsCollection(userId).doc(itemId).delete();
  }

  @override
  Future<void> clearCart(String userId) async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      FirebaseDemoStore.cartItemsById.removeWhere(
        (_, CartItemModel item) => item.userId == userId,
      );
      return;
    }

    final snapshot = await _dataSource.cartItemsCollection(userId).get();
    final WriteBatch batch = _dataSource.firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
