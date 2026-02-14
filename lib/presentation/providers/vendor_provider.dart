import 'package:flutter/foundation.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/vendor_repository.dart';

class VendorProvider extends ChangeNotifier {
  VendorProvider(this._vendorRepository);

  final VendorRepository _vendorRepository;

  List<UserModel> _vendors = <UserModel>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<UserModel> get vendors => _vendors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadApprovedVendors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _vendors = await _vendorRepository.getApprovedVendors();
    } catch (error) {
      _errorMessage = error.toString();
      _vendors = <UserModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVendorsForManagement() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _vendors = await _vendorRepository.getVendorsForManagement();
    } catch (error) {
      _errorMessage = error.toString();
      _vendors = <UserModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setVendorApproval({
    required String vendorId,
    required bool isApproved,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _vendorRepository.updateVendorApproval(vendorId: vendorId, isApproved: isApproved);
      final int index = _vendors.indexWhere((UserModel vendor) => vendor.id == vendorId);
      if (index >= 0) {
        _vendors[index] = _vendors[index].copyWith(
          isApproved: isApproved,
          updatedAt: DateTime.now(),
        );
      }
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
