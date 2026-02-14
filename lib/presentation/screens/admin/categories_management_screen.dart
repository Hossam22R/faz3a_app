import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class CategoriesManagementScreen extends StatefulWidget {
  const CategoriesManagementScreen({super.key});

  @override
  State<CategoriesManagementScreen> createState() => _CategoriesManagementScreenState();
}

class _CategoriesManagementScreenState extends State<CategoriesManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadRootCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إدارة التصنيفات')),
        body: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, _) {
            if (categoryProvider.isLoading && categoryProvider.categories.isEmpty) {
              return const Center(child: LoadingIndicator());
            }
            if (categoryProvider.errorMessage != null && categoryProvider.categories.isEmpty) {
              return AppErrorWidget(
                message: categoryProvider.errorMessage!,
                onRetry: () => context.read<CategoryProvider>().loadRootCategories(),
              );
            }
            if (categoryProvider.categories.isEmpty) {
              return const EmptyState(
                title: 'لا توجد تصنيفات حالياً',
                icon: Icons.category_rounded,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) {
                final CategoryModel category = categoryProvider.categories[index];
                return Card(
                  child: ListTile(
                    title: Text(category.nameAr ?? category.name),
                    subtitle: Text(
                      'الترتيب: ${category.sortOrder} • ${category.isActive ? 'نشط' : 'غير نشط'}',
                    ),
                    trailing: const Icon(Icons.chevron_left_rounded),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: categoryProvider.categories.length,
            );
          },
        ),
      ),
    );
  }
}
