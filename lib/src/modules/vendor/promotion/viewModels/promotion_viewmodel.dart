import 'package:flutter/material.dart';
import 'package:playspace_sport_hub_booking_system/src/models/venue_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/promotion_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/promotion/services/promotion_service.dart';

class PromotionViewModel extends ChangeNotifier {
  final PromotionService _service = PromotionService();
  List<VenueModel> vendorVenues = [];
  bool isLoading = false;

  List<PromotionModel> promotions = [];
  Map<String, int> usageCounts = {};

  Future<void> loadPromotions() async {
    isLoading = true;
    notifyListeners();

    promotions = await _service.getPromotions();
    usageCounts = await _service.getUsageCounts();

    isLoading = false;
    notifyListeners();
  }

  Future<void> reapplyPromotion(String id) async {
    await _service.reapplyPromotion(id);
    await loadPromotions();
  }

  Future<void> createPromotion(PromotionModel promotion) async {
    await _service.createPromotion(promotion);
    await loadPromotions();
  }

  Future<void> updatePromotion(PromotionModel promotion) async {
    await _service.updatePromotion(promotion);
    await loadPromotions();
  }

  Future<void> deletePromotion(String id) async {
    await _service.deletePromotion(id);
    await loadPromotions();
  }

  Future<void> togglePromotion(String id, bool active) async {
    await _service.togglePromotion(id, active);
    await loadPromotions();
  }

  Future<void> loadVendorVenues() async {
    vendorVenues = await _service.getVendorVenues();
    notifyListeners();
  }
}
