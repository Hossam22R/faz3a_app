import 'package:flutter/foundation.dart';

import '../../data/models/address_model.dart';
import '../../data/repositories/address_repository.dart';

class AddressProvider extends ChangeNotifier {
  AddressProvider(this._addressRepository);

  final AddressRepository _addressRepository;

  List<AddressModel> _addresses = <AddressModel>[];
  bool _isLoading = false;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;

  Future<void> loadAddresses(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _addresses = await _addressRepository.getUserAddresses(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
