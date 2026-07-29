import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playspace_sport_hub_booking_system/src/models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitReview(ReviewModel review) async {
    await _firestore.collection("reviews").doc(review.id).set(review.toMap());

    await updateVenueRating(review.venueId);
  }

  Future<List<ReviewModel>> getVenueReviews(String venueId) async {
    print("Searching reviews for venueId: $venueId");

    final snapshot = await _firestore
        .collection("reviews")
        .where("venueId", isEqualTo: venueId)
        .get();

    print("Found reviews: ${snapshot.docs.length}");

    for (final doc in snapshot.docs) {
      print(doc.data().toString());
    }

    return snapshot.docs.map((doc) => ReviewModel.fromMap(doc.data())).toList();
  }

  Future<void> updateVenueRating(String venueId) async {
    final reviews = await _firestore
        .collection("reviews")
        .where("venueId", isEqualTo: venueId)
        .get();

    if (reviews.docs.isEmpty) return;

    double total = 0;

    for (final doc in reviews.docs) {
      total += (doc["rating"] as num).toDouble();
    }

    final average = double.parse(
      (total / reviews.docs.length).toStringAsFixed(1),
    );

    await _firestore.collection("venues").doc(venueId).update({
      "rating": average,
      "totalReviews": reviews.docs.length,
    });
  }

  Future<List<ReviewModel>> getVendorReviews() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await _firestore
        .collection("reviews")
        .where("vendorId", isEqualTo: uid)
        .get();

    return snapshot.docs.map((e) => ReviewModel.fromMap(e.data())).toList();
  }

  Future<void> replyReview({
    required String reviewId,
    required String reply,
  }) async {
    await _firestore.collection("reviews").doc(reviewId).update({
      "reply": reply,
    });
  }
}
