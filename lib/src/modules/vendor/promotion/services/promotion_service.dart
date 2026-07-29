import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playspace_sport_hub_booking_system/src/models/promotion_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/venue_model.dart';

class PromotionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<PromotionModel>> getPromotions() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("promotions")
        .where("vendorId", isEqualTo: uid)
        .get();

    return snapshot.docs.map((e) => PromotionModel.fromMap(e.data())).toList();
  }

  Future<void> createPromotion(PromotionModel promotion) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final data = promotion.toMap();
    data["vendorId"] = uid;

    print("Creating promotion...");
    print(data);

    await _firestore.collection("promotions").doc(promotion.id).set(data);

    print("Promotion saved!");
  }

  Future<void> updatePromotion(PromotionModel promotion) async {
    await _firestore
        .collection("promotions")
        .doc(promotion.id)
        .update(promotion.toMap());
  }

  Future<void> deletePromotion(String id) async {
    await _firestore.collection("promotions").doc(id).delete();
  }

  Future<void> togglePromotion(String id, bool active) async {
    await _firestore.collection("promotions").doc(id).update({
      "isActive": active,
    });
  }

  /// Sends a rejected promotion back into the admin's review queue.
  Future<void> reapplyPromotion(String id) async {
    await _firestore.collection("promotions").doc(id).update({
      "status": "pending",
    });
  }

  /// Counts how many bookings used each of this vendor's promotions.
  Future<Map<String, int>> getUsageCounts() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("bookings")
        .where("vendorId", isEqualTo: uid)
        .get();

    final counts = <String, int>{};

    for (final doc in snapshot.docs) {
      final promotionId = doc.data()["promotionId"] as String? ?? "";

      if (promotionId.isEmpty) continue;

      counts[promotionId] = (counts[promotionId] ?? 0) + 1;
    }

    return counts;
  }

  Future<List<VenueModel>> getVendorVenues() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("venues")
        .where("vendorId", isEqualTo: uid)
        .where("status", isEqualTo: "approved")
        .get();

    return snapshot.docs.map((doc) {
      return VenueModel.fromMap({...doc.data(), "id": doc.id});
    }).toList();
  }
}
