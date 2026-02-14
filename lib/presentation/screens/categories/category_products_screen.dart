import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/cards/product_card.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.categoryId.isNotEmpty) {
        context.read<ProductProvider>().loadProductsByCategory(widget.categoryId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.categoryName?.trim().isNotEmpty == true
        ? widget.categoryName!
        : 'منتجات التصنيف';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Consumer<ProductProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: LoadingIndicator());
            }
            if (provider.errorMessage != null && provider.categoryProducts.isEmpty) {
              return AppErrorWidget(
                message: provider.errorMessage!,
                onRetry: widget.categoryId.isEmpty
                    ? null
                    : () => context.read<ProductProvider>().loadProductsByCategory(widget.categoryId),
              );
            }
            if (provider.categoryProducts.isEmpty) {
              return const EmptyState(title: 'لا توجد منتجات لهذا التصنيف');
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.categoryProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              itemBuilder: (BuildContext context, int index) {
                final ProductModel product = provider.categoryProducts[index];
                return ProductCard(
                  product: product,
                  onTap: () => context.push(AppRoutes.productDetailsLocation(product.id)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
