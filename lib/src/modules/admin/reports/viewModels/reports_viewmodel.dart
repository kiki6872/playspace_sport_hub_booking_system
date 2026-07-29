import 'package:flutter/material.dart';

import 'package:playspace_sport_hub_booking_system/src/modules/admin/reports/services/reports_service.dart';

class ReportsViewModel extends ChangeNotifier {
  final ReportsService _reportsService = ReportsService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// =========================
  /// Summary Cards
  /// =========================

  int _totalUsers = 0;
  int get totalUsers => _totalUsers;

  int _totalVenues = 0;
  int get totalVenues => _totalVenues;

  int _totalBookings = 0;
  int get totalBookings => _totalBookings;

  double _totalRevenue = 0;
  double get totalRevenue => _totalRevenue;

  /// =========================
  /// Analytics
  /// =========================

  Map<String, int> _bookingOverview = {};
  Map<String, int> get bookingOverview => _bookingOverview;

  Map<String, int> _popularSports = {};
  Map<String, int> get popularSports => _popularSports;

  Map<String, int> _peakUsage = {};
  Map<String, int> get peakUsage => _peakUsage;

  /// =========================
  /// Load All Reports
  /// =========================

  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();

    try {
      _totalUsers = await _reportsService.getTotalActiveUsers();

      _totalVenues = await _reportsService.getTotalVenues();

      _totalBookings = await _reportsService.getTotalBookings();

      _totalRevenue = await _reportsService.getTotalRevenue();

      _bookingOverview = await _reportsService.getBookingOverview();

      _popularSports = await _reportsService.getPopularSports();

      _peakUsage = await _reportsService.getPeakUsage();
    } catch (e) {
      debugPrint("Reports Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadReports();
  }
}
