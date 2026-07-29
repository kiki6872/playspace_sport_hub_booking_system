import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:playspace_sport_hub_booking_system/src/models/booking_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/vendor_wallet_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/withdrawal_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/monthly_earning_model.dart';
import 'package:intl/intl.dart';

class RevenueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<VendorWalletModel> getWallet() async {
    final uid = _auth.currentUser!.uid;

    final doc = await _firestore.collection("vendor_wallet").doc(uid).get();

    if (!doc.exists) {
      final wallet = VendorWalletModel(
        vendorId: uid,
        balance: 0,
        totalRevenue: 0,
        totalWithdrawn: 0,
      );

      await _firestore.collection("vendor_wallet").doc(uid).set(wallet.toMap());

      return wallet;
    }

    return VendorWalletModel.fromMap(doc.data()!);
  }

  Future<List<BookingModel>> getPaymentHistory() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("bookings")
        .where("vendorId", isEqualTo: uid)
        .where("status", isEqualTo: "completed")
        .get();

    return snapshot.docs.map((e) => BookingModel.fromMap(e.data())).toList();
  }

  Future<List<MonthlyEarningModel>> getMonthlySummary() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("bookings")
        .where("vendorId", isEqualTo: uid)
        .where("status", isEqualTo: "completed")
        .get();

    final Map<String, double> monthlyRevenue = {};

    for (final doc in snapshot.docs) {
      final booking = BookingModel.fromMap(doc.data());

      final key =
          "${booking.bookingDate.year}-${booking.bookingDate.month.toString().padLeft(2, '0')}";

      monthlyRevenue[key] = (monthlyRevenue[key] ?? 0) + booking.totalPrice;
    }

    final result = monthlyRevenue.entries.map((e) {
      final parts = e.key.split("-");

      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));

      return MonthlyEarningModel(
        month: DateFormat("MMMM yyyy").format(date),
        amount: e.value,
      );
    }).toList();

    result.sort((a, b) => b.month.compareTo(a.month));

    return result;
  }

  Future<List<WithdrawalModel>> getWithdrawHistory() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("withdrawals")
        .where("vendorId", isEqualTo: uid)
        .get();

    return snapshot.docs.map((e) => WithdrawalModel.fromMap(e.data())).toList();
  }

  Future<void> withdraw({required double amount}) async {
    final uid = _auth.currentUser!.uid;
    final userDoc = await _firestore.collection("users").doc(uid).get();

    final data = userDoc.data();

    if (data == null ||
        (data["bankName"] ?? "").isEmpty ||
        (data["accountNumber"] ?? "").isEmpty ||
        (data["accountHolderName"] ?? "").isEmpty) {
      throw Exception("Please set up your bank account first.");
    }

    final bankName = data["bankName"];
    final accountNumber = data["accountNumber"];
    final accountHolderName = data["accountHolderName"];

    final walletRef = _firestore.collection("vendor_wallet").doc(uid);

    final wallet = await getWallet();

    if (wallet.balance < amount) {
      throw Exception("Insufficient balance");
    }

    await walletRef.update({
      "balance": FieldValue.increment(-amount),
      "totalWithdrawn": FieldValue.increment(amount),
    });

    final doc = _firestore.collection("withdrawals").doc();

    await doc.set({
      "id": doc.id,
      "vendorId": uid,
      "amount": amount,
      "bankName": bankName,
      "accountNumber": accountNumber,
      "accountHolderName": accountHolderName,
      "status": "Completed",
      "requestedAt": DateTime.now().toIso8601String(),
    });
  }

  Future<void> addRevenue({
    required String vendorId,
    required double amount,
  }) async {
    final walletRef = _firestore.collection("vendor_wallet").doc(vendorId);

    final doc = await walletRef.get();

    if (!doc.exists) {
      await walletRef.set({
        "vendorId": vendorId,
        "balance": amount,
        "totalRevenue": amount,
        "totalWithdrawn": 0,
      });
    } else {
      await walletRef.update({
        "balance": FieldValue.increment(amount),
        "totalRevenue": FieldValue.increment(amount),
      });
    }
  }

  Future<void> syncRevenueFromBookings() async {
    final snapshot = await _firestore
        .collection("bookings")
        .where("status", isEqualTo: "completed")
        .get();

    for (final doc in snapshot.docs) {
      final booking = BookingModel.fromMap(doc.data());

      if (booking.revenueAdded) continue;

      await addRevenue(vendorId: booking.vendorId, amount: booking.totalPrice);

      await doc.reference.update({"revenueAdded": true});
    }
  }

  Future<void> rebuildVendorWallet() async {
    final snapshot = await _firestore
        .collection("bookings")
        .where("status", isEqualTo: "completed")
        .get();

    for (final doc in snapshot.docs) {
      final booking = BookingModel.fromMap(doc.data());

      await addRevenue(vendorId: booking.vendorId, amount: booking.totalPrice);
    }
  }

  Future<void> processAutoWithdraw() async {
    final today = DateTime.now();

    final snapshot = await _firestore
        .collection("users")
        .where("autoWithdraw", isEqualTo: true)
        .where("withdrawDay", isEqualTo: today.day)
        .get();

    for (final vendor in snapshot.docs) {
      final wallet = await _firestore
          .collection("vendor_wallet")
          .doc(vendor.id)
          .get();

      if (!wallet.exists) continue;

      final balance = (wallet["balance"] as num).toDouble();

      if (balance <= 0) continue;

      await withdrawForVendor(vendorId: vendor.id, amount: balance);
    }
  }

  Future<void> withdrawForVendor({
    required String vendorId,
    required double amount,
  }) async {
    final userDoc = await _firestore.collection("users").doc(vendorId).get();

    final data = userDoc.data();

    if (data == null ||
        (data["bankName"] ?? "").isEmpty ||
        (data["accountNumber"] ?? "").isEmpty ||
        (data["accountHolderName"] ?? "").isEmpty) {
      throw Exception("Vendor $vendorId has not set up their bank account.");
    }

    final bankName = data["bankName"];
    final accountNumber = data["accountNumber"];
    final accountHolderName = data["accountHolderName"];

    final walletRef = _firestore.collection("vendor_wallet").doc(vendorId);

    final wallet = await getWallet();

    if (wallet.balance < amount) {
      throw Exception("Insufficient balance for vendor $vendorId");
    }

    await walletRef.update({
      "balance": FieldValue.increment(-amount),
      "totalWithdrawn": FieldValue.increment(amount),
    });

    final doc = _firestore.collection("withdrawals").doc();

    await doc.set({
      "id": doc.id,
      "vendorId": vendorId,
      "amount": amount,
      "bankName": bankName,
      "accountNumber": accountNumber,
      "accountHolderName": accountHolderName,
      "status": "Completed",
      "requestedAt": DateTime.now().toIso8601String(),
    });
  }
}
