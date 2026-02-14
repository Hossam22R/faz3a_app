import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/category_model.dart';
import '../../widgets/cards/category_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const List<CategoryModel> _demoCategories = <CategoryModel>[
    CategoryModel(
      id: 'cat-electronics',
      name: 'Electronics',
      nameAr: 'إلكترونيات',
      createdAt: DateTime(2025, 1, 1),
    ),
    CategoryModel(
      id: 'cat-home',
      name: 'Home',
      nameAr: 'المنزل والمطبخ',
      createdAt: DateTime(2025, 1, 1),
    ),
    CategoryModel(
      id: 'cat-fashion',
      name: 'Fashion',
      nameAr: 'الأزياء',
      createdAt: DateTime(2025, 1, 1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التصنيفات')),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (BuildContext context, int index) {
            final CategoryModel category = _demoCategories[index];
            return CategoryCard(
              category: category,
              onTap: () => context.push(AppRoutes.categoryProducts),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: _demoCategories.length,
        ),
      ),
    );
  }
}
