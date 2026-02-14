import 'package:flutter/foundation.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._productRepository);

  final ProductRepository _productRepository;

  List<ProductModel> _featuredProducts = <ProductModel>[];
  List<ProductModel> _categoryProducts = <ProductModel>[];
  ProductModel? _selectedProduct;
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get categoryProducts => _categoryProducts;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadFeaturedProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _featuredProducts = await _productRepository.getFeaturedProducts();
    } catch (error) {
      _errorMessage = error.toString();
      _featuredProducts = <ProductModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProductsByCategory(String categoryId) async {
    _isLoading = true;
    _errorMessage = null;
    _categoryProducts = <ProductModel>[];
    notifyListeners();
    try {
      _categoryProducts = await _productRepository.getProductsByCategory(categoryId);
    } catch (error) {
      _errorMessage = error.toString();
      _categoryProducts = <ProductModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProductDetails(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedProduct = null;
    notifyListeners();
    try {
      _selectedProduct = await _productRepository.getProductById(productId);
      if (_selectedProduct == null) {
        _errorMessage = 'Product not found.';
      }
    } catch (error) {
      _errorMessage = error.toString();
      _selectedProduct = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
