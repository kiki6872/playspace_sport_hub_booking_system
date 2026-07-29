import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playspace_sport_hub_booking_system/src/models/venue_model.dart';

class FavouriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add favourite
  Future<void> addFavourite(String venueId) async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection("favorites").add({
      "userId": uid,
      "venueId": venueId,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// Remove favourite
  Future<void> removeFavourite(String venueId) async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("favorites")
        .where("userId", isEqualTo: uid)
        .where("venueId", isEqualTo: venueId)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Check favourite
  Future<bool> isFavourite(String venueId) async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("favorites")
        .where("userId", isEqualTo: uid)
        .where("venueId", isEqualTo: venueId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Get all favourite venue IDs
  Future<List<String>> getFavouriteVenueIds() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("favorites")
        .where("userId", isEqualTo: uid)
        .get();

    return snapshot.docs.map((e) => e["venueId"] as String).toList();
  }

  Future<List<VenueModel>> getFavouriteVenues() async {
    final uid = _auth.currentUser!.uid;

    final favSnapshot = await _firestore
        .collection("favorites")
        .where("userId", isEqualTo: uid)
        .get();

    final List<VenueModel> venues = [];

    for (final fav in favSnapshot.docs) {
      final venueId = fav["venueId"];

      final venueDoc = await _firestore.collection("venues").doc(venueId).get();

      if (venueDoc.exists) {
        venues.add(VenueModel.fromMap(venueDoc.data()!));
      }
    }

    return venues;
  }
}
