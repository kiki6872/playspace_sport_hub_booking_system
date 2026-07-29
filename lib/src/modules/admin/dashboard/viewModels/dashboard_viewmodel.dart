import 'package:flutter/material.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/dashboard/services/dashboard_services.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  int _totalUsers = 0;
  int _totalVendors = 0;
  int _totalVenues = 0;
  int get totalUsers => _totalUsers;
  int _pendingVenues = 0;
  int _pendingPromotions = 0;

  int get pendingVenues => _pendingVenues;
  int get pendingPromotions => _pendingPromotions;

  int get totalVendors => _totalVendors;
  int get totalVenues => _totalVenues;

  Future<void> loadDashboardData() async {
    try {
      _totalUsers = await _dashboardService.getTotalUsers();
      debugPrint("Users: $_totalUsers");

      _totalVendors = await _dashboardService.getTotalVendors();
      debugPrint("Vendors: $_totalVendors");

      _totalVenues = await _dashboardService.getTotalVenues();
      debugPrint("Venues: $_totalVenues");

      _pendingVenues = await _dashboardService.getPendingVenues();

      _pendingPromotions = await _dashboardService.getPendingPromotions();

      notifyListeners();
    } catch (e) {
      debugPrint("Dashboard Error: $e");
    }
  }
}
