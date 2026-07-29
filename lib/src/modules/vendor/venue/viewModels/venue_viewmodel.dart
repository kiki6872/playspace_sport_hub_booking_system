import 'package:flutter/material.dart';

import 'package:playspace_sport_hub_booking_system/src/models/venue_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/venue/services/venue_service.dart';

class VenueViewModel extends ChangeNotifier {
  final VenueService _venueService = VenueService();

  List<VenueModel> _venues = [];

  List<VenueModel> get venues => _venues;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> loadVenues() async {
    _isLoading = true;
    notifyListeners();

    _venues = await _venueService.getVendorVenues();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addVenue(VenueModel venue) async {
    await _venueService.addVenue(venue);

    await loadVenues();
  }

  Future<void> deleteVenue(String venueId) async {
    await _venueService.deleteVenue(venueId);

    await loadVenues();
  }

  Future<void> updateVenue(VenueModel venue) async {
    await _venueService.updateVenue(venue);

    await loadVenues();
  }
}
