import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:playspace_sport_hub_booking_system/src/models/booking_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/vendor_wallet_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/withdrawal_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/monthly_earning_model.dart';

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

  /// Bookings whose payment has actually been credited to this vendor's
  /// wallet - i.e. revenueAdded is true. Since revenue is now credited as
  /// soon as a booking is created (not only once it's completed), this
  /// covers ongoing and completed bookings, and excludes any booking whose
  /// revenue was reversed on cancellation.
  Future<List<BookingModel>> getPaymentHistory() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("bookings")
        .where("vendorId", isEqualTo: uid)
        .where("revenueAdded", isEqualTo: true)
        .get();

    final bookings = snapshot.docs
        .map((e) => BookingModel.fromMap(e.data()))
        .toList();

    bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

    return bookings;
  }

  Future<List<MonthlyEarningModel>> getMonthlySummary() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("bookings")
        .where("vendorId", isEqualTo: uid)
        .where("revenueAdded", isEqualTo: true)
        .get();

    final Map<String, double> monthlyRevenue = {};

    for (final doc in snapshot.docs) {
      final booking = BookingModel.fromMap(doc.data());

      final key = "${booking.bookingDate.year}-${booking.bookingDate.month}";

      monthlyRevenue[key] = (monthlyRevenue[key] ?? 0) + booking.totalPrice;
    }

    final result = monthlyRevenue.entries.map((e) {
      final parts = e.key.split("-");

      return MonthlyEarningModel(
        year: int.parse(parts[0]),
        month: int.parse(parts[1]),
        amount: e.value,
      );
    }).toList();

    result.sort((a, b) {
      final yearCompare = a.year.compareTo(b.year);
      return yearCompare != 0 ? yearCompare : a.month.compareTo(b.month);
    });

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

    // Ensure the wallet document exists before entering the transaction
    // (Firestore transactions can't create-then-read-back a doc that was
    // just lazily created by a plain get()).
    await getWallet();

    final walletRef = _firestore.collection("vendor_wallet").doc(uid);
    final withdrawalRef = _firestore.collection("withdrawals").doc();

    // Read balance, decrement it, and write the withdrawal record all in one
    // transaction so a mid-flight failure can never leave the balance
    // decremented without a matching withdrawal record (or vice versa), and
    // so the balance check can't race with a concurrent withdrawal.
    await _firestore.runTransaction((transaction) async {
      final walletSnapshot = await transaction.get(walletRef);

      final balance = walletSnapshot.exists
          ? VendorWalletModel.fromMap(walletSnapshot.data()!).balance
          : 0.0;

      if (balance < amount) {
        throw Exception("Insufficient balance");
      }

      transaction.update(walletRef, {
        "balance": FieldValue.increment(-amount),
        "totalWithdrawn": FieldValue.increment(amount),
      });

      transaction.set(withdrawalRef, {
        "id": withdrawalRef.id,
        "vendorId": uid,
        "amount": amount,
        "bankName": bankName,
        "accountNumber": accountNumber,
        "accountHolderName": accountHolderName,
        "status": "Completed",
        "requestedAt": DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> addRevenue({
    required String vendorId,
    required double amount,
  }) async {
    final walletRef = _firestore.collection("vendor_wallet").doc(vendorId);

    // Read-then-branch-then-write must happen atomically: without a
    // transaction, two concurrent addRevenue calls for a vendor with no
    // existing wallet doc could both see "not exists" and both call set(),
    // with the second overwriting (not adding to) the first's amount.
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(walletRef);

      if (!snapshot.exists) {
        transaction.set(walletRef, {
          "vendorId": vendorId,
          "balance": amount,
          "totalRevenue": amount,
          "totalWithdrawn": 0,
        });
      } else {
        transaction.update(walletRef, {
          "balance": FieldValue.increment(amount),
          "totalRevenue": FieldValue.increment(amount),
        });
      }
    });
  }

  /// Reverses a previously-credited addRevenue() call, e.g. when a booking
  /// whose revenue was already added gets cancelled.
  Future<void> reverseRevenue({
    required String vendorId,
    required double amount,
  }) async {
    final walletRef = _firestore.collection("vendor_wallet").doc(vendorId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(walletRef);

      if (!snapshot.exists) return;

      transaction.update(walletRef, {
        "balance": FieldValue.increment(-amount),
        "totalRevenue": FieldValue.increment(-amount),
      });
    });
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
    final withdrawalRef = _firestore.collection("withdrawals").doc();

    // Bug fix: this used to call getWallet(), which reads the wallet of
    // FirebaseAuth.instance.currentUser — not the `vendorId` passed in — so
    // an auto-withdraw run for vendor A could check vendor B's (or the
    // caller's own) balance instead. Read the target vendor's wallet doc
    // directly, and do the balance check + writes atomically like withdraw().
    await _firestore.runTransaction((transaction) async {
      final walletSnapshot = await transaction.get(walletRef);

      final balance = walletSnapshot.exists
          ? VendorWalletModel.fromMap(walletSnapshot.data()!).balance
          : 0.0;

      if (balance < amount) {
        throw Exception("Insufficient balance for vendor $vendorId");
      }

      transaction.update(walletRef, {
        "balance": FieldValue.increment(-amount),
        "totalWithdrawn": FieldValue.increment(amount),
      });

      transaction.set(withdrawalRef, {
        "id": withdrawalRef.id,
        "vendorId": vendorId,
        "amount": amount,
        "bankName": bankName,
        "accountNumber": accountNumber,
        "accountHolderName": accountHolderName,
        "status": "Completed",
        "requestedAt": DateTime.now().toIso8601String(),
      });
    });
  }
}
