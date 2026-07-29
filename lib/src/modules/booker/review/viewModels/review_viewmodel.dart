import 'package:flutter/material.dart';

import 'package:playspace_sport_hub_booking_system/src/models/review_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/review/services/review_service.dart';

class ReviewViewModel extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<ReviewModel> _reviews = [];

  List<ReviewModel> get reviews => _reviews;

  Future<void> submitReview(ReviewModel review) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _reviewService.submitReview(review);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVenueReviews(String venueId) async {
    _reviews = await _reviewService.getVenueReviews(venueId);
    notifyListeners();
  }

  Future<void> loadVendorReviews() async {
    _isLoading = true;
    notifyListeners();

    _reviews = await _reviewService.getVendorReviews();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> replyReview({
    required String reviewId,
    required String reply,
  }) async {
    await _reviewService.replyReview(reviewId: reviewId, reply: reply);

    await loadVendorReviews();
  }
}
