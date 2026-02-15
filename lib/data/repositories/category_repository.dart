import '../models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getRootCategories();
  Future<List<CategoryModel>> getSubCategories(String parentCategoryId);
}
