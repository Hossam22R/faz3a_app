import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/review_model.dart';
import '../../providers/review_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/rating_stars.dart';

class ProductReviewsScreen extends StatefulWidget {
  const ProductReviewsScreen({super.key});

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  static const String _demoProductId = 'demo-p1';
  static const List<ReviewModel> _fallbackReviews = <ReviewModel>[
    ReviewModel(
      id: 'r1',
      productId: _demoProductId,
      userId: 'u1',
      userName: 'مستخدم 1',
      rating: 4.5,
      comment: 'منتج ممتاز وجودة عالية.',
      isVerifiedPurchase: true,
      createdAt: DateTime(2025, 1, 1),
    ),
    ReviewModel(
      id: 'r2',
      productId: _demoProductId,
      userId: 'u2',
      userName: 'مستخدم 2',
      rating: 4.0,
      comment: 'توصيل سريع والتغليف جيد.',
      isVerifiedPurchase: true,
      createdAt: DateTime(2025, 1, 2),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().loadProductReviews(_demoProductId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تقييمات المنتج')),
        body: Consumer<ReviewProvider>(
          builder: (context, reviewProvider, _) {
            final List<ReviewModel> reviews =
                reviewProvider.reviews.isNotEmpty ? reviewProvider.reviews : _fallbackReviews;

            if (reviewProvider.isLoading) {
              return const Center(child: LoadingIndicator());
            }
            if (reviewProvider.errorMessage != null && reviewProvider.reviews.isEmpty) {
              return AppErrorWidget(
                message: reviewProvider.errorMessage!,
                onRetry: () => reviewProvider.loadProductReviews(_demoProductId),
              );
            }
            if (reviews.isEmpty) {
              return const EmptyState(title: 'لا توجد تقييمات بعد');
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final ReviewModel review = reviews[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              review.userName,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            RatingStars(rating: review.rating),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(review.comment ?? ''),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: reviews.length,
            );
          },
        ),
      ),
    );
  }
}
