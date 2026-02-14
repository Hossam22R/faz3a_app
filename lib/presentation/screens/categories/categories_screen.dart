import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../widgets/cards/category_card.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  static const List<CategoryModel> _fallbackCategories = <CategoryModel>[
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final CategoryProvider provider = context.read<CategoryProvider>();
      if (!provider.isLoading && provider.categories.isEmpty) {
        provider.loadRootCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التصنيفات')),
        body: Consumer<CategoryProvider>(
          builder: (context, provider, _) {
            final List<CategoryModel> categories =
                provider.categories.isNotEmpty ? provider.categories : _fallbackCategories;

            if (provider.isLoading) {
              return const Center(child: LoadingIndicator());
            }
            if (provider.errorMessage != null && provider.categories.isEmpty) {
              return AppErrorWidget(
                message: provider.errorMessage!,
                onRetry: provider.loadRootCategories,
              );
            }
            if (categories.isEmpty) {
              return const EmptyState(title: 'لا توجد تصنيفات حالياً');
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) {
                final CategoryModel category = categories[index];
                return CategoryCard(
                  category: category,
                  onTap: () => context.push(AppRoutes.categoryProducts),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: categories.length,
            );
          },
        ),
      ),
    );
  }
}
