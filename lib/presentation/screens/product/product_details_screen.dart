import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
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
  static final ProductModel _fallbackProduct = ProductModel(
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
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProductData());
  }

  Future<void> _loadProductData() async {
    if (widget.productId.isEmpty) {
      return;
    }
    final ProductProvider productProvider = context.read<ProductProvider>();
    await productProvider.loadProductDetails(widget.productId);
    final ProductModel? loadedProduct = productProvider.selectedProduct;
    if (loadedProduct != null && loadedProduct.categoryId.isNotEmpty) {
      await productProvider.loadProductsByCategory(loadedProduct.categoryId);
    }
  }

  Future<void> _addToCart(ProductModel product) async {
    final String? userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
      );
      return;
    }
    if (!product.isInStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('المنتج غير متوفر حالياً')),
      );
      return;
    }

    final int safeQuantity = _quantity > product.stock ? product.stock : _quantity;
    final CartProvider cartProvider = context.read<CartProvider>();
    await cartProvider.addProduct(
      userId: userId,
      product: product,
      quantity: safeQuantity,
    );
    if (!mounted) {
      return;
    }
    final bool success = cartProvider.errorMessage == null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'تمت إضافة $safeQuantity قطعة إلى السلة'
              : cartProvider.errorMessage!,
        ),
        action: success
            ? SnackBarAction(
                label: 'السلة',
                onPressed: () => context.push(AppRoutes.cart),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل المنتج')),
        body: Consumer<ProductProvider>(
          builder: (context, productProvider, _) {
            final ProductModel? selectedProduct = productProvider.selectedProduct;
            final ProductModel? product = selectedProduct ??
                (widget.productId.isEmpty ? _fallbackProduct : null);

            if (productProvider.isLoading && product == null) {
              return const Center(child: LoadingIndicator());
            }
            if (productProvider.errorMessage != null && product == null) {
              return AppErrorWidget(
                message: productProvider.errorMessage!,
                onRetry: _loadProductData,
              );
            }
            if (product == null) {
              return AppErrorWidget(
                message: 'تعذر العثور على المنتج المطلوب.',
                onRetry: _loadProductData,
              );
            }

            final int displayQuantity = product.stock <= 0
                ? 1
                : (_quantity > product.stock ? product.stock : _quantity);
            final List<ProductModel> relatedProducts = productProvider.categoryProducts
                .where((ProductModel item) => item.categoryId == product.categoryId && item.id != product.id)
                .take(4)
                .toList();

            return RefreshIndicator(
              onRefresh: _loadProductData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  if (product.images.isEmpty)
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_outlined, size: 52),
                    )
                  else
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          final String imageUrl = product.images[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 300,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.black12,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.broken_image_outlined, size: 44),
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemCount: product.images.length,
                      ),
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
                    runSpacing: 8,
                    children: <Widget>[
                      if (product.hasDiscount)
                        BadgeWidget(label: 'خصم ${product.discountPercentage}%'),
                      BadgeWidget(label: product.isInStock ? 'مخزون متوفر' : 'غير متوفر'),
                      BadgeWidget(label: 'تم الطلب ${product.ordersCount} مرة'),
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
                  const SizedBox(height: 12),
                  if (product.isInStock)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              onPressed: displayQuantity > 1
                                  ? () => setState(() {
                                        _quantity = displayQuantity - 1;
                                      })
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text(
                              '$displayQuantity',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            IconButton(
                              onPressed: displayQuantity < product.stock
                                  ? () => setState(() {
                                        _quantity = displayQuantity + 1;
                                      })
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                            const Spacer(),
                            Text('المتوفر: ${product.stock}'),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: AddToCartButton(
                          onPressed: product.isInStock ? () => _addToCart(product) : null,
                          label: product.isInStock ? 'أضف للسلة' : 'غير متوفر',
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => context.push(AppRoutes.productReviewsLocation(product.id)),
                        child: const Text('التقييمات'),
                      ),
                    ],
                  ),
                  if (relatedProducts.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 16),
                    const Text(
                      'منتجات مشابهة',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    ...relatedProducts.map(
                      (ProductModel related) => Card(
                        child: ListTile(
                          title: Text(related.name),
                          subtitle: Text('${related.finalPrice.toStringAsFixed(0)} IQD'),
                          trailing: const Icon(Icons.chevron_left_rounded),
                          onTap: () => context.push(AppRoutes.productDetailsLocation(related.id)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
