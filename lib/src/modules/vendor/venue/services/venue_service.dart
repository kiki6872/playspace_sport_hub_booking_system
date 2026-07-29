import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:playspace_sport_hub_booking_system/src/models/venue_model.dart';

class VenueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add Venue
  Future<void> addVenue(VenueModel venue) async {
    await _firestore.collection('venues').doc(venue.id).set(venue.toMap());
  }

  /// Get Current Vendor Venues
  Future<List<VenueModel>> getVendorVenues() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection('venues')
        .where('vendorId', isEqualTo: uid)
        .get();

    return snapshot.docs.map((doc) => VenueModel.fromMap(doc.data())).toList();
  }

  /// Update Venue
  Future<void> updateVenue(VenueModel venue) async {
    await _firestore.collection('venues').doc(venue.id).update(venue.toMap());
  }

  /// Delete Venue
  Future<void> deleteVenue(String venueId) async {
    await _firestore.collection('venues').doc(venueId).delete();
  }

  Future<List<VenueModel>> getAllVenues() async {
    final snapshot = await _firestore.collection('venues').get();

    return snapshot.docs.map((doc) => VenueModel.fromMap(doc.data())).toList();
  }

  Future<void> approveVenue(String venueId) async {
    await _firestore.collection('venues').doc(venueId).update({
      'status': 'approved',
    });
  }

  Future<void> rejectVenue(String venueId) async {
    await _firestore.collection('venues').doc(venueId).update({
      'status': 'rejected',
    });
  }
}
