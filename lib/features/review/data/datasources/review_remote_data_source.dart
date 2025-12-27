import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../../../../core/constants/app_constants.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getReviewsByUser(String userId);
  Future<List<ReviewModel>> getReviewsByRestaurant(String restaurantId);
  Future<ReviewModel> createReview({
    required String userId,
    required String restaurantId,
    required String text,
    required double rating,
  });
  Future<ReviewModel> updateReview(
    String reviewId, {
    String? text,
    double? rating,
  });
  Future<void> deleteReview(String reviewId);
  Future<ReviewModel?> getUserReviewForRestaurant(String userId, String restaurantId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final FirebaseFirestore firestore;

  ReviewRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ReviewModel>> getReviewsByUser(String userId) async {
    final querySnapshot = await firestore
        .collection(AppConstants.reviewsCollection)
        .where('userId', isEqualTo: userId)
        .get();

    // Sort client-side to avoid composite index requirement
    final reviews = querySnapshot.docs
        .map((doc) => ReviewModel.fromFirestore(doc))
        .toList();
    
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return reviews;
  }

  @override
  Future<List<ReviewModel>> getReviewsByRestaurant(String restaurantId) async {
    final querySnapshot = await firestore
        .collection(AppConstants.reviewsCollection)
        .where('restaurantId', isEqualTo: restaurantId)
        .get();

    // Sort client-side to avoid composite index requirement
    final reviews = querySnapshot.docs
        .map((doc) => ReviewModel.fromFirestore(doc))
        .toList();
    
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return reviews;
  }

  @override
  Future<ReviewModel> createReview({
    required String userId,
    required String restaurantId,
    required String text,
    required double rating,
  }) async {
    final now = DateTime.now();
    final review = ReviewModel(
      id: '',
      userId: userId,
      restaurantId: restaurantId,
      text: text,
      rating: rating,
      createdAt: now,
      updatedAt: now,
    );

    final docRef = await firestore.collection(AppConstants.reviewsCollection).add(review.toFirestore());
    final doc = await docRef.get();

    return ReviewModel.fromFirestore(doc);
  }

  @override
  Future<ReviewModel> updateReview(
    String reviewId, {
    String? text,
    double? rating,
  }) async {
    final updateData = <String, dynamic>{
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };

    if (text != null) updateData['text'] = text;
    if (rating != null) updateData['rating'] = rating;

    await firestore.collection(AppConstants.reviewsCollection).doc(reviewId).update(updateData);

    final doc = await firestore.collection(AppConstants.reviewsCollection).doc(reviewId).get();
    return ReviewModel.fromFirestore(doc);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await firestore.collection(AppConstants.reviewsCollection).doc(reviewId).delete();
  }

  @override
  Future<ReviewModel?> getUserReviewForRestaurant(String userId, String restaurantId) async {
    final querySnapshot = await firestore
        .collection(AppConstants.reviewsCollection)
        .where('userId', isEqualTo: userId)
        .where('restaurantId', isEqualTo: restaurantId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    final doc = querySnapshot.docs.first;
    return ReviewModel.fromFirestore(doc);
  }
}