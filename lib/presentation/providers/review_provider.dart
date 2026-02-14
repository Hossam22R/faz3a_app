import 'package:flutter/foundation.dart';

import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  ReviewProvider(this._reviewRepository);

  final ReviewRepository _reviewRepository;

  List<ReviewModel> _reviews = <ReviewModel>[];
  bool _isLoading = false;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;

  Future<void> loadProductReviews(String productId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _reviews = await _reviewRepository.getProductReviews(productId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
