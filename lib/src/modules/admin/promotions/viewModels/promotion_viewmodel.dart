import 'package:flutter/material.dart';

import 'package:playspace_sport_hub_booking_system/src/models/promotion_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/promotions/services/promotion_service.dart';

class PromotionViewModel extends ChangeNotifier {
  final AdminPromotionService _service = AdminPromotionService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PromotionModel> _pendingPromotions = [];
  List<PromotionModel> _activePromotions = [];

  List<PromotionModel> _completedPromotions = [];
  List<PromotionModel> _rejectedPromotions = [];

  List<PromotionModel> get pendingPromotions => _pendingPromotions;
  List<PromotionModel> get activePromotions => _activePromotions;
  List<PromotionModel> get completedPromotions => _completedPromotions;
  List<PromotionModel> get rejectedPromotions => _rejectedPromotions;

  Future<void> loadPromotions() async {
    _isLoading = true;
    notifyListeners();

    _pendingPromotions = await _service.getPendingPromotions();

    _activePromotions = await _service.getActivePromotions();

    _completedPromotions = await _service.getCompletedPromotions();
    _rejectedPromotions = await _service.getRejectedPromotions();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> approve(String id) async {
    await _service.approvePromotion(id);
    await loadPromotions();
  }

  Future<void> reject(String id) async {
    await _service.rejectPromotion(id);
    await loadPromotions();
  }
}
