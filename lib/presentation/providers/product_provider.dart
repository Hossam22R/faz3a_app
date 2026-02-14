import 'package:flutter/foundation.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._productRepository);

  final ProductRepository _productRepository;

  List<ProductModel> _featuredProducts = <ProductModel>[];
  List<ProductModel> _categoryProducts = <ProductModel>[];
  List<ProductModel> _vendorProducts = <ProductModel>[];
  List<ProductModel> _pendingProducts = <ProductModel>[];
  ProductModel? _selectedProduct;
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get categoryProducts => _categoryProducts;
  List<ProductModel> get vendorProducts => _vendorProducts;
  List<ProductModel> get pendingProducts => _pendingProducts;
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

  Future<void> loadVendorProducts(String vendorId) async {
    _isLoading = true;
    _errorMessage = null;
    _vendorProducts = <ProductModel>[];
    notifyListeners();
    try {
      _vendorProducts = await _productRepository.getVendorProducts(vendorId);
    } catch (error) {
      _errorMessage = error.toString();
      _vendorProducts = <ProductModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveVendorProduct(ProductModel product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _productRepository.upsertProduct(product);
      final int index = _vendorProducts.indexWhere((ProductModel item) => item.id == product.id);
      if (index >= 0) {
        _vendorProducts[index] = product;
      } else {
        _vendorProducts = <ProductModel>[product, ..._vendorProducts];
      }
      _selectedProduct = product;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingProductsForApproval() async {
    _isLoading = true;
    _errorMessage = null;
    _pendingProducts = <ProductModel>[];
    notifyListeners();
    try {
      _pendingProducts = await _productRepository.getPendingProductsForApproval();
    } catch (error) {
      _errorMessage = error.toString();
      _pendingProducts = <ProductModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProductApprovalStatus({
    required String productId,
    required ProductStatus status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _productRepository.updateProductStatus(productId: productId, status: status);
      final int pendingIndex =
          _pendingProducts.indexWhere((ProductModel product) => product.id == productId);
      if (pendingIndex >= 0) {
        if (status == ProductStatus.pending) {
          _pendingProducts[pendingIndex] =
              _pendingProducts[pendingIndex].copyWith(status: status, updatedAt: DateTime.now());
        } else {
          _pendingProducts.removeAt(pendingIndex);
        }
      }
      final int vendorIndex = _vendorProducts.indexWhere((ProductModel product) => product.id == productId);
      if (vendorIndex >= 0) {
        _vendorProducts[vendorIndex] =
            _vendorProducts[vendorIndex].copyWith(status: status, updatedAt: DateTime.now());
      }
      if (_selectedProduct?.id == productId) {
        _selectedProduct = _selectedProduct!.copyWith(status: status, updatedAt: DateTime.now());
      }
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
