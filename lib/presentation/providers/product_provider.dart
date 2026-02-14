import 'package:flutter/foundation.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._productRepository);

  final ProductRepository _productRepository;

  List<ProductModel> _featuredProducts = <ProductModel>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get featuredProducts => _featuredProducts;
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
}
