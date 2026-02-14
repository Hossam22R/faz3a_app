import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/exceptions.dart';
import '../../data_sources/remote/firebase_data_source.dart';
import '../../models/product_model.dart';
import '../product_repository.dart';
import 'firebase_repository_utils.dart';

class FirebaseProductRepository implements ProductRepository {
  FirebaseProductRepository(this._dataSource);

  final FirebaseDataSource _dataSource;

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    if (!isFirebaseReady) {
      return const <ProductModel>[];
    }

    final snapshot = await _dataSource
        .productsCollection()
        .where('isActive', isEqualTo: true)
        .limit(40)
        .get();

    final List<ProductModel> products = snapshot.docs
        .map(
          (doc) => ProductModel.fromJson(<String, dynamic>{
            ...doc.data(),
            'id': doc.data()['id'] ?? doc.id,
          }),
        )
        .where(_isVisibleProduct)
        .toList();

    products.sort((ProductModel a, ProductModel b) {
      if (a.isFeatured == b.isFeatured) {
        return b.createdAt.compareTo(a.createdAt);
      }
      return a.isFeatured ? -1 : 1;
    });

    return products;
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    if (!isFirebaseReady) {
      return const <ProductModel>[];
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _dataSource
        .productsCollection()
        .where('isActive', isEqualTo: true)
        .where('categoryId', isEqualTo: categoryId)
        .limit(120)
        .get();

    final List<ProductModel> products = snapshot.docs
        .map(
          (doc) => ProductModel.fromJson(<String, dynamic>{
            ...doc.data(),
            'id': doc.data()['id'] ?? doc.id,
          }),
        )
        .where(_isVisibleProduct)
        .toList();

    products.sort((ProductModel a, ProductModel b) => b.createdAt.compareTo(a.createdAt));
    return products;
  }

  @override
  Future<ProductModel?> getProductById(String productId) async {
    if (!isFirebaseReady) {
      return null;
    }

    final doc = await _dataSource.productsCollection().doc(productId).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return ProductModel.fromJson(<String, dynamic>{
      ...doc.data()!,
      'id': doc.data()!['id'] ?? doc.id,
    });
  }

  Future<void> upsertProduct(ProductModel product) async {
    if (!isFirebaseReady) {
      throw const AppException('Firebase is not initialized.');
    }
    await _dataSource.productsCollection().doc(product.id).set(product.toJson(), SetOptions(merge: true));
  }

  bool _isVisibleProduct(ProductModel product) {
    return product.status == ProductStatus.approved || product.status == ProductStatus.pending;
  }
}
