import 'package:flutter/foundation.dart';

import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  ReviewProvider(this._reviewRepository);

  final ReviewRepository _reviewRepository;

  List<ReviewModel> _reviews = <ReviewModel>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProductReviews(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _reviews = await _reviewRepository.getProductReviews(productId);
    } catch (error) {
      _errorMessage = error.toString();
      _reviews = <ReviewModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
