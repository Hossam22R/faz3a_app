import 'package:flutter/foundation.dart';

import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider(this._categoryRepository);

  final CategoryRepository _categoryRepository;

  List<CategoryModel> _categories = <CategoryModel>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadRootCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _categories = await _categoryRepository.getRootCategories();
    } catch (error) {
      _errorMessage = error.toString();
      _categories = <CategoryModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
