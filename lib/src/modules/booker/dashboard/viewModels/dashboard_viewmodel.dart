import 'package:flutter/material.dart';

import 'package:playspace_sport_hub_booking_system/src/models/venue_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/venue/services/venue_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playspace_sport_hub_booking_system/src/models/booking_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/booking/services/booking_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final VenueService _venueService = VenueService();
  final BookingService _bookingService = BookingService();
  String _selectedSport = "All";

  String get selectedSport => _selectedSport;

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String _userName = "";

  String get userName => _userName;
  String _profileImage = "";

  String get profileImage => _profileImage;

  List<VenueModel> _venues = [];

  List<VenueModel> get venues => _venues;
  List<BookingModel> _latestBookings = [];

  List<BookingModel> get latestBookings => _latestBookings;
  void filterSport(String sport) {
    _selectedSport = sport;
    notifyListeners();
  }

  List<VenueModel> get filteredVenues {
    if (_selectedSport == "All") {
      return venues;
    }

    return venues.where((venue) {
      return venue.sportType == _selectedSport;
    }).toList();
  }

  Future<void> loadVenues() async {
    try {
      _isLoading = true;
      notifyListeners();

      _venues = await _venueService.getVenues();

      debugPrint('Total venues: ${_venues.length}');

      for (final venue in _venues) {
        debugPrint(venue.name);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      debugPrint(doc.data().toString());

      _userName = doc.data()?['fullName'] ?? "User";
      _profileImage = doc.data()?['profileImage'] ?? "";
      debugPrint("Booker Name: $_userName");

      notifyListeners();
    }
  }

  List<VenueModel> searchVenues(String keyword) {
    if (keyword.isEmpty) return _venues;

    return _venues.where((venue) {
      return venue.name.toLowerCase().contains(keyword.toLowerCase()) ||
          venue.address.toLowerCase().contains(keyword.toLowerCase()) ||
          venue.sportType.toLowerCase().contains(keyword.toLowerCase());
    }).toList();
  }

  Future<void> loadLatestBookings() async {
    try {
      _latestBookings = await _bookingService.getBookerBookings();

      if (_latestBookings.length > 3) {
        _latestBookings = _latestBookings.take(3).toList();
      }

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
