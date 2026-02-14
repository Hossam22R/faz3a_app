import 'package:flutter/foundation.dart';

import '../../data/models/address_model.dart';
import '../../data/repositories/address_repository.dart';

class AddressProvider extends ChangeNotifier {
  AddressProvider(this._addressRepository);

  final AddressRepository _addressRepository;

  List<AddressModel> _addresses = <AddressModel>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAddresses(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _addresses = await _addressRepository.getUserAddresses(userId);
    } catch (error) {
      _errorMessage = error.toString();
      _addresses = <AddressModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveAddress(AddressModel address) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _addressRepository.upsertAddress(address);
      final int index = _addresses.indexWhere((AddressModel item) => item.id == address.id);
      if (index >= 0) {
        _addresses[index] = address;
      } else {
        _addresses = <AddressModel>[address, ..._addresses];
      }
      if (address.isDefault) {
        _addresses = _addresses
            .map((AddressModel item) => item.id == address.id ? item : item.copyWith(isDefault: false))
            .toList();
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
