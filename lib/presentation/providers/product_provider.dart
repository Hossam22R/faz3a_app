import 'package:flutter/foundation.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._productRepository);

  final ProductRepository _productRepository;

  List<ProductModel> _featuredProducts = <ProductModel>[];
  bool _isLoading = false;

  List<ProductModel> get featuredProducts => _featuredProducts;
  bool get isLoading => _isLoading;

  Future<void> loadFeaturedProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _featuredProducts = await _productRepository.getFeaturedProducts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
