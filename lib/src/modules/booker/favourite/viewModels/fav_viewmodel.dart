import 'package:flutter/material.dart';
import 'package:playspace_sport_hub_booking_system/src/models/venue_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/favourite/services/fav_service.dart';

class FavouriteViewModel extends ChangeNotifier {
  final FavouriteService _service = FavouriteService();

  final Set<String> _favouriteVenueIds = {};
  List<VenueModel> venues = [];

  Set<String> get favouriteVenueIds => _favouriteVenueIds;

  bool isLoading = false;

  /// Load all favourites
  Future<void> loadFavourites() async {
    isLoading = true;
    notifyListeners();

    final ids = await _service.getFavouriteVenueIds();

    _favouriteVenueIds
      ..clear()
      ..addAll(ids);

    isLoading = false;
    notifyListeners();
  }

  /// Check favourite
  bool isFavourite(String venueId) {
    return _favouriteVenueIds.contains(venueId);
  }

  /// Toggle favourite
  Future<void> toggleFavourite(String venueId) async {
    if (_favouriteVenueIds.contains(venueId)) {
      await _service.removeFavourite(venueId);

      _favouriteVenueIds.remove(venueId);
    } else {
      await _service.addFavourite(venueId);

      _favouriteVenueIds.add(venueId);
    }

    notifyListeners();
  }

  Future<void> loadFavouriteVenues() async {
    isLoading = true;
    notifyListeners();

    venues = await _service.getFavouriteVenues();

    isLoading = false;
    notifyListeners();
  }
}
