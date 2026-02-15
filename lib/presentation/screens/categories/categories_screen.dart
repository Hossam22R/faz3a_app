import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  Future<void> _loadCategories() async {
    await context.read<CategoryProvider>().loadRootCategories();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.primaryDark,
        appBar: AppBar(
          title: const Text('التصنيفات'),
          actions: <Widget>[
            IconButton(
              tooltip: 'بحث',
              onPressed: () => context.push(AppRoutes.search),
              icon: const Icon(Icons.search_rounded),
            ),
            IconButton(
              tooltip: 'السلة',
              onPressed: () => context.push(AppRoutes.cart),
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
          ],
        ),
        body: Consumer<CategoryProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.categories.isEmpty) {
              return const Center(child: LoadingIndicator());
            }
            if (provider.errorMessage != null && provider.categories.isEmpty) {
              return AppErrorWidget(
                message: provider.errorMessage!,
                onRetry: _loadCategories,
              );
            }
            if (provider.categories.isEmpty) {
              return const EmptyState(
                title: 'لا توجد تصنيفات حالياً',
                subtitle: 'سيتم عرض التصنيفات فور إضافتها من لوحة الإدارة.',
              );
            }

            return RefreshIndicator(
              onRefresh: _loadCategories,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double horizontalPadding = constraints.maxWidth > 700
                      ? (constraints.maxWidth - 700) / 2
                      : 16;
                  final int crossAxisCount = constraints.maxWidth > 620 ? 3 : 2;

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 18),
                    children: <Widget>[
                      _CategoriesHero(total: provider.categories.length),
                      const SizedBox(height: 14),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.categories.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final CategoryModel category = provider.categories[index];
                          return _CategoryTile(
                            category: category,
                            onTap: () => context.push(
                              AppRoutes.categoryProductsLocation(
                                category.id,
                                categoryName: category.nameAr ?? category.name,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoriesHero extends StatelessWidget {
  const _CategoriesHero({
    required this.total,
  });

  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.category_rounded, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'تسوق حسب الفئة',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'عدد التصنيفات المتاحة: $total',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onTap,
  });

  final CategoryModel category;
  final VoidCallback onTap;

  IconData _iconFor(String key) {
    final String normalized = key.toLowerCase();
    if (normalized.contains('elect') || normalized.contains('إلكتر')) {
      return Icons.devices_other_rounded;
    }
    if (normalized.contains('fashion') || normalized.contains('أزي')) {
      return Icons.checkroom_rounded;
    }
    if (normalized.contains('home') || normalized.contains('منزل') || normalized.contains('مطبخ')) {
      return Icons.kitchen_rounded;
    }
    if (normalized.contains('kids') || normalized.contains('طفل') || normalized.contains('ألعاب')) {
      return Icons.toys_rounded;
    }
    if (normalized.contains('book') || normalized.contains('كتب')) {
      return Icons.menu_book_rounded;
    }
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final String label = category.nameAr ?? category.name;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF202020),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_iconFor(label), color: AppColors.primaryGold),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_left_rounded, size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
