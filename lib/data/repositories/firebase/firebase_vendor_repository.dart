import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/exceptions.dart';
import '../../data_sources/remote/firebase_data_source.dart';
import '../../models/user_model.dart';
import '../vendor_repository.dart';
import 'firebase_repository_utils.dart';

class FirebaseVendorRepository implements VendorRepository {
  FirebaseVendorRepository(this._dataSource);

  final FirebaseDataSource _dataSource;

  @override
  Future<List<UserModel>> getApprovedVendors() async {
    if (!isFirebaseReady) {
      return const <UserModel>[];
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _dataSource
        .usersCollection()
        .where('userType', isEqualTo: UserType.vendor.name)
        .where('isApproved', isEqualTo: true)
        .limit(100)
        .get();

    return snapshot.docs
        .map(
          (doc) => UserModel.fromJson(<String, dynamic>{
            ...doc.data(),
            'id': doc.data()['id'] ?? doc.id,
          }),
        )
        .toList();
  }

  @override
  Future<void> updateVendorApproval({
    required String vendorId,
    required bool isApproved,
  }) async {
    if (!isFirebaseReady) {
      throw const AppException('Firebase is not initialized.');
    }
    await _dataSource.usersCollection().doc(vendorId).set(
      <String, dynamic>{
        'isApproved': isApproved,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
