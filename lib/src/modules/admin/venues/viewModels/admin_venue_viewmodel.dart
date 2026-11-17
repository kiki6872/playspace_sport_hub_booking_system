import 'package:flutter/material.dart';
import 'package:playspace_sport_hub_booking_system/src/models/venue_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/venue/services/venue_service.dart';

class AdminVenueViewModel extends ChangeNotifier {
  final VenueService _venueService = VenueService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<VenueModel> _venues = [];
  List<VenueModel> get venues => _venues;

  Future<void> loadVenues() async {
    _isLoading = true;
    notifyListeners();

    _venues = await _venueService.getAllVenues();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> approveVenue(String venueId) async {
    await _venueService.approveVenue(venueId);
    await loadVenues();
  }

  Future<void> rejectVenue(String venueId) async {
    await _venueService.rejectVenue(venueId);
    await loadVenues();
  }
}
