import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:playspace_sport_hub_booking_system/src/models/reward_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/user_voucher_model.dart';

class RewardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<RewardModel> getReward() async {
    final uid = _auth.currentUser!.uid;

    final doc = await _firestore.collection("rewards").doc(uid).get();

    if (!doc.exists) {
      final reward = RewardModel(userId: uid, points: 0);

      await _firestore.collection("rewards").doc(uid).set(reward.toMap());

      return reward;
    }

    return RewardModel.fromMap(doc.data()!);
  }

  Future<void> addPoints({required String userId, required int points}) async {
    await _firestore.collection("rewards").doc(userId).update({
      "points": FieldValue.increment(points),
    });
  }

  Future<void> deductPoints({
    required String userId,
    required int points,
  }) async {
    await _firestore.collection("rewards").doc(userId).update({
      "points": FieldValue.increment(-points),
    });
  }

  Future<void> redeemVoucher({
    required String title,
    required int requiredPoints,
    required int discount,
  }) async {
    final uid = _auth.currentUser!.uid;

    print("Redeem clicked");
    print("UID: $uid");

    final reward = await getReward();

    print("Current Points: ${reward.points}");

    if (reward.points < requiredPoints) {
      print("Not enough points");
      throw Exception("Not enough points");
    }

    print("Deducting points...");

    await deductPoints(userId: uid, points: requiredPoints);

    final doc = _firestore.collection("user_vouchers").doc();

    await doc.set({
      "id": doc.id,
      "userId": uid,
      "title": title,
      "discount": discount,
      "status": "active",
      "redeemedAt": DateTime.now().toIso8601String(),
    });

    print("Voucher saved");
  }

  Future<List<UserVoucherModel>> getUserVouchers() async {
    final uid = _auth.currentUser!.uid;

    print("Current UID: $uid");

    final snapshot = await _firestore
        .collection("user_vouchers")
        .where("userId", isEqualTo: uid)
        .get();

    print("Voucher found: ${snapshot.docs.length}");

    for (final doc in snapshot.docs) {
      print(doc.data());
    }

    return snapshot.docs
        .map((doc) => UserVoucherModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> useVoucher(String voucherId) async {
    await _firestore.collection("user_vouchers").doc(voucherId).update({
      "status": "used",
    });
  }
}
