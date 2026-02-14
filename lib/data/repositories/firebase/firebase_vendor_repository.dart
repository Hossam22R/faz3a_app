import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/exceptions.dart';
import '../../data_sources/remote/firebase_data_source.dart';
import '../../models/user_model.dart';
import '../vendor_repository.dart';
import 'firebase_demo_store.dart';
import 'firebase_repository_utils.dart';

class FirebaseVendorRepository implements VendorRepository {
  FirebaseVendorRepository(this._dataSource);

  final FirebaseDataSource _dataSource;

  @override
  Future<List<UserModel>> getApprovedVendors() async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      return FirebaseDemoStore.usersById.values
          .where(
            (UserModel user) => user.userType == UserType.vendor && user.isApproved == true,
          )
          .toList();
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
  Future<List<UserModel>> getVendorsForManagement() async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      final List<UserModel> vendors = FirebaseDemoStore.usersById.values
          .where((UserModel user) => user.userType == UserType.vendor)
          .toList();
      vendors.sort((UserModel a, UserModel b) => b.createdAt.compareTo(a.createdAt));
      return vendors;
    }
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _dataSource
        .usersCollection()
        .where('userType', isEqualTo: UserType.vendor.name)
        .limit(200)
        .get();

    final List<UserModel> vendors = snapshot.docs
        .map(
          (doc) => UserModel.fromJson(<String, dynamic>{
            ...doc.data(),
            'id': doc.data()['id'] ?? doc.id,
          }),
        )
        .toList();
    vendors.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return vendors;
  }

  @override
  Future<void> updateVendorApproval({
    required String vendorId,
    required bool isApproved,
  }) async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      final UserModel? vendor = FirebaseDemoStore.usersById[vendorId];
      if (vendor == null) {
        throw const AppException('Vendor not found.');
      }
      FirebaseDemoStore.usersById[vendorId] = vendor.copyWith(
        isApproved: isApproved,
        updatedAt: DateTime.now(),
      );
      return;
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
