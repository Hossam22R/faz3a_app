import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/exceptions.dart';
import '../../data_sources/remote/firebase_data_source.dart';
import '../../models/review_model.dart';
import '../review_repository.dart';
import 'firebase_repository_utils.dart';

class FirebaseReviewRepository implements ReviewRepository {
  FirebaseReviewRepository(this._dataSource);

  final FirebaseDataSource _dataSource;

  @override
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    if (!isFirebaseReady) {
      return const <ReviewModel>[];
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _dataSource
        .reviewsCollection()
        .where('productId', isEqualTo: productId)
        .where('isApproved', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    return snapshot.docs
        .map(
          (doc) => ReviewModel.fromJson(<String, dynamic>{
            ...doc.data(),
            'id': doc.data()['id'] ?? doc.id,
          }),
        )
        .toList();
  }

  @override
  Future<void> submitReview(ReviewModel review) async {
    if (!isFirebaseReady) {
      throw const AppException('Firebase is not initialized.');
    }
    await _dataSource.reviewsCollection().doc(review.id).set(review.toJson(), SetOptions(merge: true));
  }
}
