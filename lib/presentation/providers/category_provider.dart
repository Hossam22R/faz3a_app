import 'package:flutter/foundation.dart';

import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider(this._categoryRepository);

  final CategoryRepository _categoryRepository;

  List<CategoryModel> _categories = <CategoryModel>[];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadRootCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await _categoryRepository.getRootCategories();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
