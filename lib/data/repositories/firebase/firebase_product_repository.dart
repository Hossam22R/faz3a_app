import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/exceptions.dart';
import '../../data_sources/remote/firebase_data_source.dart';
import '../../models/product_model.dart';
import '../product_repository.dart';
import 'firebase_demo_store.dart';
import 'firebase_repository_utils.dart';

class FirebaseProductRepository implements ProductRepository {
  FirebaseProductRepository(this._dataSource);

  final FirebaseDataSource _dataSource;

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      final List<ProductModel> products = FirebaseDemoStore.productsById.values
          .where(
            (ProductModel product) => product.isActive && _isVisibleProduct(product),
          )
          .toList();
      products.sort((ProductModel a, ProductModel b) {
        if (a.isFeatured == b.isFeatured) {
          return b.createdAt.compareTo(a.createdAt);
        }
        return a.isFeatured ? -1 : 1;
      });
      return products;
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
      FirebaseDemoStore.ensureInitialized();
      final List<ProductModel> products = FirebaseDemoStore.productsById.values
          .where(
            (ProductModel product) =>
                product.isActive &&
                product.categoryId == categoryId &&
                _isVisibleProduct(product),
          )
          .toList();
      products.sort((ProductModel a, ProductModel b) => b.createdAt.compareTo(a.createdAt));
      return products;
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
  Future<List<ProductModel>> getVendorProducts(String vendorId) async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      final List<ProductModel> products = FirebaseDemoStore.productsById.values
          .where((ProductModel product) => product.vendorId == vendorId)
          .toList();
      products.sort((ProductModel a, ProductModel b) => b.createdAt.compareTo(a.createdAt));
      return products;
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _dataSource
        .productsCollection()
        .where('vendorId', isEqualTo: vendorId)
        .limit(200)
        .get();

    final List<ProductModel> products = snapshot.docs
        .map(
          (doc) => ProductModel.fromJson(<String, dynamic>{
            ...doc.data(),
            'id': doc.data()['id'] ?? doc.id,
          }),
        )
        .toList();

    products.sort((ProductModel a, ProductModel b) => b.createdAt.compareTo(a.createdAt));
    return products;
  }

  @override
  Future<List<ProductModel>> getPendingProductsForApproval() async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      final List<ProductModel> products = FirebaseDemoStore.productsById.values
          .where((ProductModel product) => product.status == ProductStatus.pending)
          .toList();
      products.sort((ProductModel a, ProductModel b) => b.createdAt.compareTo(a.createdAt));
      return products;
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _dataSource
        .productsCollection()
        .where('status', isEqualTo: ProductStatus.pending.name)
        .limit(200)
        .get();

    final List<ProductModel> products = snapshot.docs
        .map(
          (doc) => ProductModel.fromJson(<String, dynamic>{
            ...doc.data(),
            'id': doc.data()['id'] ?? doc.id,
          }),
        )
        .toList();

    products.sort((ProductModel a, ProductModel b) => b.createdAt.compareTo(a.createdAt));
    return products;
  }

  @override
  Future<ProductModel?> getProductById(String productId) async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      return FirebaseDemoStore.productsById[productId];
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

  @override
  Future<void> upsertProduct(ProductModel product) async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      FirebaseDemoStore.productsById[product.id] = product;
      return;
    }
    await _dataSource.productsCollection().doc(product.id).set(product.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> updateProductStatus({
    required String productId,
    required ProductStatus status,
  }) async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      final ProductModel? existing = FirebaseDemoStore.productsById[productId];
      if (existing == null) {
        throw const AppException('Product not found.');
      }
      FirebaseDemoStore.productsById[productId] = existing.copyWith(
        status: status,
        isActive: status == ProductStatus.rejected ? false : existing.isActive,
        updatedAt: DateTime.now(),
      );
      return;
    }
    await _dataSource.productsCollection().doc(productId).set(
      <String, dynamic>{
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
        if (status == ProductStatus.rejected) 'isActive': false,
      },
      SetOptions(merge: true),
    );
  }

  bool _isVisibleProduct(ProductModel product) {
    return product.status == ProductStatus.approved || product.status == ProductStatus.pending;
  }
}
