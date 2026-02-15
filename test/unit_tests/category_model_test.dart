import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nema_store/data/models/category_model.dart';

void main() {
  group('CategoryModel', () {
    test('supports Timestamp deserialization', () {
      final DateTime now = DateTime.now();
      final CategoryModel category = CategoryModel.fromJson(<String, dynamic>{
        'id': 'cat_1',
        'name': 'Electronics',
        'createdAt': Timestamp.fromDate(now),
      });

      expect(category.id, 'cat_1');
      expect(category.name, 'Electronics');
      expect(category.createdAt.year, now.year);
    });
  });
}
