import '../models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  Future<List<ProductModel>> getVendorProducts(String vendorId);
  Future<ProductModel?> getProductById(String productId);
  Future<void> upsertProduct(ProductModel product);
}
