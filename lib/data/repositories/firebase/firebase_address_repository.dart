import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/exceptions.dart';
import '../../data_sources/remote/firebase_data_source.dart';
import '../../models/address_model.dart';
import '../address_repository.dart';
import 'firebase_repository_utils.dart';

class FirebaseAddressRepository implements AddressRepository {
  FirebaseAddressRepository(this._dataSource);

  final FirebaseDataSource _dataSource;

  @override
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    if (!isFirebaseReady) {
      return const <AddressModel>[];
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _dataSource
        .addressesCollection()
        .where('userId', isEqualTo: userId)
        .orderBy('isDefault', descending: true)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => AddressModel.fromJson(<String, dynamic>{
            ...doc.data(),
            'id': doc.data()['id'] ?? doc.id,
          }),
        )
        .toList();
  }

  @override
  Future<void> upsertAddress(AddressModel address) async {
    if (!isFirebaseReady) {
      throw const AppException('Firebase is not initialized.');
    }

    final WriteBatch batch = _dataSource.firestore.batch();

    if (address.isDefault) {
      final oldDefaults = await _dataSource
          .addressesCollection()
          .where('userId', isEqualTo: address.userId)
          .where('isDefault', isEqualTo: true)
          .get();
      for (final doc in oldDefaults.docs) {
        batch.update(doc.reference, <String, dynamic>{
          'isDefault': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    batch.set(
      _dataSource.addressesCollection().doc(address.id),
      address.toJson(),
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}
