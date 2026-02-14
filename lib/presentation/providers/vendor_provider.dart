import 'package:flutter/foundation.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/vendor_repository.dart';

class VendorProvider extends ChangeNotifier {
  VendorProvider(this._vendorRepository);

  final VendorRepository _vendorRepository;

  List<UserModel> _vendors = <UserModel>[];
  bool _isLoading = false;

  List<UserModel> get vendors => _vendors;
  bool get isLoading => _isLoading;

  Future<void> loadApprovedVendors() async {
    _isLoading = true;
    notifyListeners();
    try {
      _vendors = await _vendorRepository.getApprovedVendors();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
