import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

enum _ProductsSort { popular, newest, priceLow, priceHigh, topRated }

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({
    required this.categoryId,
    this.categoryName,
    super.key,
  });

  final String categoryId;
  final String? categoryName;

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  _ProductsSort _sortBy = _ProductsSort.popular;

  Future<void> _loadProducts() async {
    if (widget.categoryId.isEmpty) {
      return;
    }
    await context.read<ProductProvider>().loadProductsByCategory(widget.categoryId);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProducts());
  }

  List<ProductModel> _sortedProducts(List<ProductModel> source) {
    final List<ProductModel> sorted = List<ProductModel>.from(source);
    switch (_sortBy) {
      case _ProductsSort.popular:
        sorted.sort((ProductModel a, ProductModel b) {
          final int byOrders = b.ordersCount.compareTo(a.ordersCount);
          if (byOrders != 0) {
            return byOrders;
          }
          return b.rating.compareTo(a.rating);
        });
        return sorted;
      case _ProductsSort.newest:
        sorted.sort((ProductModel a, ProductModel b) => b.createdAt.compareTo(a.createdAt));
        return sorted;
      case _ProductsSort.priceLow:
        sorted.sort((ProductModel a, ProductModel b) => a.finalPrice.compareTo(b.finalPrice));
        return sorted;
      case _ProductsSort.priceHigh:
        sorted.sort((ProductModel a, ProductModel b) => b.finalPrice.compareTo(a.finalPrice));
        return sorted;
      case _ProductsSort.topRated:
        sorted.sort((ProductModel a, ProductModel b) => b.rating.compareTo(a.rating));
        return sorted;
    }
  }

  String _sortLabel(_ProductsSort sort) {
    switch (sort) {
      case _ProductsSort.popular:
        return 'الأكثر مبيعًا';
      case _ProductsSort.newest:
        return 'الأحدث';
      case _ProductsSort.priceLow:
        return 'سعر أقل';
      case _ProductsSort.priceHigh:
        return 'سعر أعلى';
      case _ProductsSort.topRated:
        return 'تقييم أعلى';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.categoryName?.trim().isNotEmpty == true
        ? widget.categoryName!
        : 'منتجات التصنيف';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.primaryDark,
        appBar: AppBar(
          title: Text(title),
          actions: <Widget>[
            IconButton(
              tooltip: 'بحث',
              onPressed: () => context.push(AppRoutes.search),
              icon: const Icon(Icons.search_rounded),
            ),
          ],
        ),
        body: Consumer<ProductProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.categoryProducts.isEmpty) {
              return const Center(child: LoadingIndicator());
            }
            if (provider.errorMessage != null && provider.categoryProducts.isEmpty) {
              return AppErrorWidget(
                message: provider.errorMessage!,
                onRetry: _loadProducts,
              );
            }
            if (provider.categoryProducts.isEmpty) {
              return const EmptyState(
                title: 'لا توجد منتجات لهذا التصنيف',
                subtitle: 'جرّب تصنيفًا آخر من صفحة التصنيفات.',
              );
            }
            final List<ProductModel> products = _sortedProducts(provider.categoryProducts);

            return RefreshIndicator(
              onRefresh: _loadProducts,
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
                      _ProductsSummaryCard(
                        title: title,
                        count: products.length,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _ProductsSort.values.map(
                          (_ProductsSort sort) {
                            return ChoiceChip(
                              label: Text(_sortLabel(sort)),
                              selected: _sortBy == sort,
                              onSelected: (_) {
                                setState(() {
                                  _sortBy = sort;
                                });
                              },
                            );
                          },
                        ).toList(),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final ProductModel product = products[index];
                          return _CategoryProductTile(
                            product: product,
                            onTap: () => context.push(AppRoutes.productDetailsLocation(product.id)),
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

class _ProductsSummaryCard extends StatelessWidget {
  const _ProductsSummaryCard({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('عدد المنتجات: $count', style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryProductTile extends StatelessWidget {
  const _CategoryProductTile({
    required this.product,
    required this.onTap,
  });

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF202020),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.14)),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: product.images.isEmpty
                      ? const Icon(Icons.image_outlined, size: 34)
                      : Image.network(
                          product.images.first,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, size: 34),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                if (product.hasDiscount)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'خصم ${product.discountPercentage}%',
                      style: const TextStyle(fontSize: 10, color: AppColors.primaryGold),
                    ),
                  ),
                const Spacer(),
                Icon(
                  product.isInStock ? Icons.check_circle_outline : Icons.remove_circle_outline,
                  size: 14,
                  color: product.isInStock ? Colors.greenAccent : Colors.redAccent,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${product.finalPrice.toStringAsFixed(0)} IQD',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryGold),
            ),
          ],
        ),
      ),
    );
  }
}
