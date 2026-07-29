import 'package:flutter/material.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/dashboard/services/vendor_dashboard_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final VendorDashboardService _dashboardService = VendorDashboardService();

  int _totalVenues = 0;

  int get totalVenues => _totalVenues;

  int _todayBookings = 0;

  int get todayBookings => _todayBookings;

  int _pendingVenues = 0;

  int get pendingVenues => _pendingVenues;

  double _revenue = 0;

  double get revenue => _revenue;
  List<Map<String, dynamic>> _todaySchedule = [];

  List<Map<String, dynamic>> get todaySchedule => _todaySchedule;
  List<Map<String, dynamic>> _recentActivities = [];

  List<Map<String, dynamic>> get recentActivities => _recentActivities;

  Future<void> loadDashboardData() async {
    _totalVenues = await _dashboardService.getTotalVenues();

    _pendingVenues = await _dashboardService.getPendingVenues();

    _todayBookings = await _dashboardService.getTotalBookings();

    _revenue = await _dashboardService.getRevenue();
    _todaySchedule = await _dashboardService.getTodayBookings();
    _recentActivities = await _dashboardService.getRecentActivities();
    notifyListeners();
  }
}
