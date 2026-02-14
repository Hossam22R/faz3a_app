import '../models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  Future<ProductModel?> getProductById(String productId);
}
