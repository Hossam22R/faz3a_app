import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/buttons/add_to_cart_button.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/badge_widget.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/rating_stars.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    required this.productId,
    super.key,
  });

  final String productId;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  static const ProductModel _fallbackProduct = ProductModel(
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.productId.isNotEmpty) {
        context.read<ProductProvider>().loadProductDetails(widget.productId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل المنتج')),
        body: Consumer<ProductProvider>(
          builder: (context, productProvider, _) {
            final ProductModel? resolved = productProvider.selectedProduct;
            final ProductModel product = resolved ?? _fallbackProduct;

            if (productProvider.isLoading && resolved == null) {
              return const Center(child: LoadingIndicator());
            }
            if (productProvider.errorMessage != null && resolved == null) {
              return AppErrorWidget(
                message: productProvider.errorMessage!,
                onRetry: widget.productId.isEmpty
                    ? null
                    : () => context.read<ProductProvider>().loadProductDetails(widget.productId),
              );
            }

            return ListView(
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
                  product.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    RatingStars(rating: product.rating, size: 18),
                    const SizedBox(width: 8),
                    Text('${product.reviewsCount} تقييم'),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: <Widget>[
                    if (product.hasDiscount)
                      BadgeWidget(label: 'خصم ${product.discountPercentage}%'),
                    BadgeWidget(label: product.isInStock ? 'مخزون متوفر' : 'غير متوفر'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${product.finalPrice.toStringAsFixed(0)} IQD',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                if (product.hasDiscount) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(0)} IQD',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Text(product.description),
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
                      onPressed: () => context.push(AppRoutes.productReviewsLocation(product.id)),
                      child: const Text('التقييمات'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
