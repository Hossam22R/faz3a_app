import '../models/user_model.dart';

abstract class VendorRepository {
  Future<List<UserModel>> getApprovedVendors();
  Future<void> updateVendorApproval({
    required String vendorId,
    required bool isApproved,
  });
}
