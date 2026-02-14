import '../models/review_model.dart';

abstract class ReviewRepository {
  Future<List<ReviewModel>> getProductReviews(String productId);
  Future<void> submitReview(ReviewModel review);
}
