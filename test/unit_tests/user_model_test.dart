import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nema_store/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('serializes and deserializes correctly', () {
      final DateTime now = DateTime.now();
      final UserModel model = UserModel(
        id: 'u1',
        fullName: 'User One',
        email: 'user1@example.com',
        phone: '+9647000000000',
        userType: UserType.customer,
        createdAt: now,
        savedAddresses: const <String>['addr_1'],
        wishlist: const <String>['p1'],
      );

      final Map<String, dynamic> json = model.toJson();
      expect(json['createdAt'], isA<Timestamp>());

      final UserModel fromJson = UserModel.fromJson(<String, dynamic>{
        ...json,
        'createdAt': Timestamp.fromDate(now),
      });

      expect(fromJson.id, 'u1');
      expect(fromJson.userType, UserType.customer);
      expect(fromJson.savedAddresses, contains('addr_1'));
    });
  });
}
