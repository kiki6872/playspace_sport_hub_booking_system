import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VendorDashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getVendorName() async {
    final uid = _auth.currentUser!.uid;

    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return "Vendor";

    return doc.data()?['fullName'] ?? "Vendor";
  }

  Future<int> getTotalVenues() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection('venues')
        .where('vendorId', isEqualTo: uid)
        .get();

    return snapshot.docs.length;
  }

  Future<int> getPendingVenues() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection('venues')
        .where('vendorId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .get();

    return snapshot.docs.length;
  }

  Future<int> getTotalBookings() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("bookings")
        .where("vendorId", isEqualTo: uid)
        .where("status", whereIn: ["approved", "completed"])
        .get();

    return snapshot.docs.length;
  }

  Future<double> getRevenue() async {
    final uid = _auth.currentUser!.uid;

    final doc = await _firestore.collection("vendor_wallet").doc(uid).get();

    if (!doc.exists) {
      return 0;
    }

    return (doc.data()?["totalRevenue"] as num?)?.toDouble() ?? 0;
  }

  Future<List<Map<String, dynamic>>> getTodayBookings() async {
    final uid = _auth.currentUser!.uid;

    final today = DateTime.now();

    final date = DateTime(today.year, today.month, today.day);

    final snapshot = await _firestore
        .collection("bookings")
        .where("vendorId", isEqualTo: uid)
        .where("status", whereIn: ["approved", "completed"])
        .get();

    return snapshot.docs
        .where((doc) {
          final bookingDate = DateTime.parse(doc["bookingDate"]);

          return bookingDate.year == date.year &&
              bookingDate.month == date.month &&
              bookingDate.day == date.day;
        })
        .map((e) => e.data())
        .toList();
  }

  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("bookings")
        .where("vendorId", isEqualTo: uid)
        .get();

    final activities = snapshot.docs.map((e) => e.data()).toList();

    activities.sort(
      (a, b) =>
          (b["bookingDate"] as String).compareTo(a["bookingDate"] as String),
    );

    return activities.take(5).toList();
  }
}
