import '../models/address_model.dart';

abstract class AddressRepository {
  Future<List<AddressModel>> getUserAddresses(String userId);
  Future<void> upsertAddress(AddressModel address);
}
