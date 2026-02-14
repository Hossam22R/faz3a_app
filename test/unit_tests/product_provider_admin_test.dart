import 'package:flutter_test/flutter_test.dart';
import 'package:nema_store/data/models/product_model.dart';
import 'package:nema_store/data/repositories/product_repository.dart';
import 'package:nema_store/presentation/providers/product_provider.dart';

class _FakeProductRepository implements ProductRepository {
  final Map<String, ProductModel> _products = <String, ProductModel>{};
  final Set<String> _pendingIds = <String>{};

  void seed(ProductModel product) {
    _products[product.id] = product;
    if (product.status == ProductStatus.pending) {
      _pendingIds.add(product.id);
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    return _products.values.toList();
  }

  @override
  Future<ProductModel?> getProductById(String productId) async {
    return _products[productId];
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    return _products.values.where((ProductModel p) => p.categoryId == categoryId).toList();
  }

  @override
  Future<List<ProductModel>> getVendorProducts(String vendorId) async {
    return _products.values.where((ProductModel p) => p.vendorId == vendorId).toList();
  }

  @override
  Future<List<ProductModel>> getPendingProductsForApproval() async {
    return _pendingIds.map((String id) => _products[id]!).toList();
  }

  @override
  Future<void> upsertProduct(ProductModel product) async {
    _products[product.id] = product;
    if (product.status == ProductStatus.pending) {
      _pendingIds.add(product.id);
    }
  }

  @override
  Future<void> updateProductStatus({
    required String productId,
    required ProductStatus status,
  }) async {
    final ProductModel? existing = _products[productId];
    if (existing == null) {
      return;
    }
    _products[productId] = existing.copyWith(status: status);
    if (status == ProductStatus.pending) {
      _pendingIds.add(productId);
    } else {
      _pendingIds.remove(productId);
    }
  }
}

void main() {
  group('ProductProvider admin flow', () {
    test('loads pending products and approves one', () async {
      final _FakeProductRepository repository = _FakeProductRepository();
      final ProductModel pending = ProductModel(
        id: 'p1',
        vendorId: 'v1',
        name: 'Pending Product',
        description: 'Desc',
        categoryId: 'c1',
        price: 10000,
        stock: 4,
        images: const <String>[],
        status: ProductStatus.pending,
        createdAt: DateTime.now(),
      );
      repository.seed(pending);
      final ProductProvider provider = ProductProvider(repository);

      await provider.loadPendingProductsForApproval();
      expect(provider.pendingProducts, hasLength(1));
      expect(provider.pendingProducts.first.id, 'p1');

      final bool result = await provider.updateProductApprovalStatus(
        productId: 'p1',
        status: ProductStatus.approved,
      );

      expect(result, isTrue);
      expect(provider.pendingProducts, isEmpty);
    });
  });
}
