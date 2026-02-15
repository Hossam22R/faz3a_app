import 'package:flutter_test/flutter_test.dart';
import 'package:nema_store/data/models/user_model.dart';
import 'package:nema_store/data/repositories/vendor_repository.dart';
import 'package:nema_store/presentation/providers/vendor_provider.dart';

class _FakeVendorRepository implements VendorRepository {
  final Map<String, UserModel> _vendors = <String, UserModel>{};

  void seed(UserModel vendor) {
    _vendors[vendor.id] = vendor;
  }

  @override
  Future<List<UserModel>> getApprovedVendors() async {
    return _vendors.values.where((UserModel vendor) => vendor.isApproved == true).toList();
  }

  @override
  Future<List<UserModel>> getVendorsForManagement() async {
    return _vendors.values.toList();
  }

  @override
  Future<void> updateVendorApproval({
    required String vendorId,
    required bool isApproved,
  }) async {
    final UserModel? vendor = _vendors[vendorId];
    if (vendor == null) {
      return;
    }
    _vendors[vendorId] = vendor.copyWith(
      isApproved: isApproved,
      updatedAt: DateTime.now(),
    );
  }
}

void main() {
  group('VendorProvider', () {
    test('loads vendors and toggles approval', () async {
      final _FakeVendorRepository repository = _FakeVendorRepository();
      repository.seed(
        UserModel(
          id: 'v1',
          fullName: 'Vendor 1',
          email: 'v1@test.com',
          phone: '07000000000',
          userType: UserType.vendor,
          isApproved: false,
          createdAt: DateTime.now(),
        ),
      );

      final VendorProvider provider = VendorProvider(repository);
      await provider.loadVendorsForManagement();
      expect(provider.vendors, hasLength(1));
      expect(provider.vendors.first.isApproved, isFalse);

      final bool ok = await provider.setVendorApproval(vendorId: 'v1', isApproved: true);
      expect(ok, isTrue);
      expect(provider.vendors.first.isApproved, isTrue);
    });
  });
}
