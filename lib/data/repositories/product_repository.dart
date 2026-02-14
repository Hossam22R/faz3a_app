import '../models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  Future<List<ProductModel>> getVendorProducts(String vendorId);
  Future<List<ProductModel>> getPendingProductsForApproval();
  Future<ProductModel?> getProductById(String productId);
  Future<void> upsertProduct(ProductModel product);
  Future<void> updateProductStatus({
    required String productId,
    required ProductStatus status,
  });
}
