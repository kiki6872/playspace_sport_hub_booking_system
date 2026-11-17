import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playspace_sport_hub_booking_system/src/models/promotion_model.dart';

class AdminPromotionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<PromotionModel>> getPendingPromotions() async {
    final snapshot = await _firestore
        .collection("promotions")
        .where("status", isEqualTo: "pending")
        .get();

    return snapshot.docs
        .map((doc) => PromotionModel.fromMap(doc.data()))
        .toList();
  }

  Future<List<PromotionModel>> getActivePromotions() async {
    final snapshot = await _firestore
        .collection("promotions")
        .where("status", isEqualTo: "approved")
        .get();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return snapshot.docs.map((doc) => PromotionModel.fromMap(doc.data())).where(
      (promotion) {
        final endDate = DateTime(
          promotion.endDate.year,
          promotion.endDate.month,
          promotion.endDate.day,
        );

        return !today.isAfter(endDate);
      },
    ).toList();
  }

  Future<List<PromotionModel>> getCompletedPromotions() async {
    final snapshot = await _firestore
        .collection("promotions")
        .where("status", isEqualTo: "approved")
        .get();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return snapshot.docs.map((doc) => PromotionModel.fromMap(doc.data())).where(
      (promotion) {
        final endDate = DateTime(
          promotion.endDate.year,
          promotion.endDate.month,
          promotion.endDate.day,
        );

        return today.isAfter(endDate);
      },
    ).toList();
  }

  Future<void> approvePromotion(String promotionId) async {
    await _firestore.collection("promotions").doc(promotionId).update({
      "status": "approved",
      "isActive": true,
    });
  }

  Future<void> rejectPromotion(String promotionId) async {
    await _firestore.collection("promotions").doc(promotionId).update({
      "status": "rejected",
      "isActive": false,
    });
  }

  Future<List<PromotionModel>> getRejectedPromotions() async {
    final snapshot = await _firestore
        .collection("promotions")
        .where("status", isEqualTo: "rejected")
        .get();

    return snapshot.docs
        .map((doc) => PromotionModel.fromMap(doc.data()))
        .toList();
  }
}
