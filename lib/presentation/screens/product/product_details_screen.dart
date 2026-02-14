import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/product_model.dart';
import '../../widgets/buttons/add_to_cart_button.dart';
import '../../widgets/common/badge_widget.dart';
import '../../widgets/common/rating_stars.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  static const ProductModel _product = ProductModel(
    id: 'details-demo',
    vendorId: 'v1',
    name: 'سماعات لاسلكية',
    description: 'سماعات بجودة صوت عالية مع عزل ضوضاء وبطارية طويلة.',
    categoryId: 'electronics',
    price: 45000,
    discountPrice: 39000,
    stock: 15,
    images: <String>[],
    rating: 4.5,
    reviewsCount: 82,
    createdAt: DateTime(2025, 1, 1),
  );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل المنتج')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.image_outlined, size: 52),
            ),
            const SizedBox(height: 12),
            Text(
              _product.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                RatingStars(rating: _product.rating, size: 18),
                const SizedBox(width: 8),
                const Text('82 تقييم'),
              ],
            ),
            const SizedBox(height: 10),
            const Wrap(
              spacing: 8,
              children: <Widget>[
                BadgeWidget(label: 'خصم 13%'),
                BadgeWidget(label: 'مخزون متوفر'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${_product.finalPrice} IQD',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(_product.description),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: AddToCartButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت إضافة المنتج إلى السلة')),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => context.push(AppRoutes.productReviews),
                  child: const Text('التقييمات'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
