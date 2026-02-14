import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/review_model.dart';
import '../../providers/review_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/rating_stars.dart';

class ProductReviewsScreen extends StatefulWidget {
  const ProductReviewsScreen({
    required this.productId,
    super.key,
  });

  final String productId;

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.productId.isNotEmpty) {
        context.read<ReviewProvider>().loadProductReviews(widget.productId);
      }
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
            if (reviewProvider.isLoading) {
              return const Center(child: LoadingIndicator());
            }
            if (reviewProvider.errorMessage != null && reviewProvider.reviews.isEmpty) {
              return AppErrorWidget(
                message: reviewProvider.errorMessage!,
                onRetry: widget.productId.isEmpty
                    ? null
                    : () => reviewProvider.loadProductReviews(widget.productId),
              );
            }
            if (reviewProvider.reviews.isEmpty) {
              return const EmptyState(title: 'لا توجد تقييمات بعد');
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final ReviewModel review = reviewProvider.reviews[index];
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
              itemCount: reviewProvider.reviews.length,
            );
          },
        ),
      ),
    );
  }
}
