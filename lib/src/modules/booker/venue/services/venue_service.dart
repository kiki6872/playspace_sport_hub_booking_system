import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:playspace_sport_hub_booking_system/src/models/venue_model.dart';

class VenueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<VenueModel>> getVenues() async {
    final snapshot = await _firestore
        .collection('venues')
        .where('status', isEqualTo: 'approved')
        .get();

    debugPrint('Approved venues: ${snapshot.docs.length}');

    return snapshot.docs.map((doc) {
      return VenueModel.fromMap(doc.data());
    }).toList();
  }

  Future<void> createVenue(VenueModel venue) async {
    await _firestore.collection('venues').doc(venue.id).set(venue.toMap());
  }

  Future<void> updateVenue(VenueModel venue) async {
    await _firestore.collection('venues').doc(venue.id).update(venue.toMap());
  }

  Future<void> deleteVenue(String venueId) async {
    await _firestore.collection('venues').doc(venueId).delete();
  }
}
