import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/product_model.dart';
import '../../widgets/cards/product_card.dart';

class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({super.key});

  static const List<ProductModel> _products = <ProductModel>[
    ProductModel(
      id: 'cat-p1',
      vendorId: 'v1',
      name: 'مكنسة كهربائية',
      description: 'منتج تجريبي',
      categoryId: 'cat-home',
      price: 78000,
      stock: 4,
      images: <String>[],
      createdAt: DateTime(2025, 1, 1),
    ),
    ProductModel(
      id: 'cat-p2',
      vendorId: 'v2',
      name: 'غلاية ماء',
      description: 'منتج تجريبي',
      categoryId: 'cat-home',
      price: 25000,
      stock: 10,
      images: <String>[],
      createdAt: DateTime(2025, 1, 1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('منتجات التصنيف')),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.62,
          ),
          itemBuilder: (BuildContext context, int index) {
            final ProductModel product = _products[index];
            return ProductCard(
              product: product,
              onTap: () => context.push(AppRoutes.productDetails),
            );
          },
        ),
      ),
    );
  }
}
