import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data_sources/remote/firebase_data_source.dart';
import '../../models/category_model.dart';
import '../category_repository.dart';
import 'firebase_demo_store.dart';
import 'firebase_repository_utils.dart';

class FirebaseCategoryRepository implements CategoryRepository {
  FirebaseCategoryRepository(this._dataSource);

  final FirebaseDataSource _dataSource;

  @override
  Future<List<CategoryModel>> getRootCategories() async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      final List<CategoryModel> categories = FirebaseDemoStore.categoriesById.values
          .where((CategoryModel category) => category.isActive && category.isRootCategory)
          .toList();
      categories.sort((CategoryModel a, CategoryModel b) => a.sortOrder.compareTo(b.sortOrder));
      return categories;
    }

    QuerySnapshot<Map<String, dynamic>> snapshot = await _dataSource
        .categoriesCollection()
        .where('isActive', isEqualTo: true)
        .where('parentId', isNull: true)
        .orderBy('sortOrder')
        .get();

    if (snapshot.docs.isEmpty) {
      snapshot = await _dataSource
          .categoriesCollection()
          .where('isActive', isEqualTo: true)
          .where('parentId', isEqualTo: '')
          .orderBy('sortOrder')
          .get();
    }

    return snapshot.docs
        .map(
          (doc) => CategoryModel.fromJson(<String, dynamic>{
            ...doc.data(),
            'id': doc.data()['id'] ?? doc.id,
          }),
        )
        .toList();
  }

  @override
  Future<List<CategoryModel>> getSubCategories(String parentCategoryId) async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      final List<CategoryModel> categories = FirebaseDemoStore.categoriesById.values
          .where(
            (CategoryModel category) => category.isActive && category.parentId == parentCategoryId,
          )
          .toList();
      categories.sort((CategoryModel a, CategoryModel b) => a.sortOrder.compareTo(b.sortOrder));
      return categories;
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _dataSource
        .categoriesCollection()
        .where('isActive', isEqualTo: true)
        .where('parentId', isEqualTo: parentCategoryId)
        .orderBy('sortOrder')
        .get();

    return snapshot.docs
        .map(
          (doc) => CategoryModel.fromJson(<String, dynamic>{
            ...doc.data(),
            'id': doc.data()['id'] ?? doc.id,
          }),
        )
        .toList();
  }
}
