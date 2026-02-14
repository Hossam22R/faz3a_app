import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nema_store/data/models/product_model.dart';

void main() {
  group('ProductModel', () {
    test('computes discount flags and final price', () {
      final ProductModel product = ProductModel(
        id: 'p1',
        vendorId: 'v1',
        name: 'Mixer',
        description: 'Kitchen mixer',
        categoryId: 'c1',
        price: 100000,
        discountPrice: 80000,
        stock: 3,
        images: const <String>['img1'],
        createdAt: DateTime.now(),
      );

      expect(product.hasDiscount, isTrue);
      expect(product.finalPrice, 80000);
      expect(product.discountPercentage, 20);
    });

    test('deserializes date fields from Timestamp', () {
      final DateTime now = DateTime.now();
      final ProductModel product = ProductModel.fromJson(<String, dynamic>{
        'id': 'p2',
        'vendorId': 'v2',
        'name': 'Laptop',
        'description': 'Gaming laptop',
        'categoryId': 'electronics',
        'price': 2000,
        'stock': 10,
        'images': <String>['img2'],
        'createdAt': Timestamp.fromDate(now),
      });

      expect(product.createdAt.year, now.year);
      expect(product.status, ProductStatus.pending);
      expect(product.adPackage, AdPackage.none);
    });
  });
}
