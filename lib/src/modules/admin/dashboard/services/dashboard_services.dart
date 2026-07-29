import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalUsers() async {
    final snapshot = await _firestore.collection('users').get();

    debugPrint("Users Count: ${snapshot.docs.length}");

    return snapshot.docs.length;
  }

  Future<int> getTotalVendors() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'vendor')
        .get();

    debugPrint("Vendors Count: ${snapshot.docs.length}");

    for (final doc in snapshot.docs) {
      debugPrint(doc.data().toString());
    }

    return snapshot.docs.length;
  }

  Future<int> getTotalVenues() async {
    final snapshot = await _firestore.collection('venues').get();

    debugPrint("Venues Count: ${snapshot.docs.length}");

    for (final doc in snapshot.docs) {
      debugPrint(doc.data().toString());
    }

    return snapshot.docs.length;
  }

  Future<int> getPendingVenues() async {
    final snapshot = await _firestore
        .collection("venues")
        .where("status", isEqualTo: "pending")
        .get();

    return snapshot.docs.length;
  }

  Future<int> getPendingPromotions() async {
    final snapshot = await _firestore
        .collection("promotions")
        .where("status", isEqualTo: "pending")
        .get();

    return snapshot.docs.length;
  }
}
