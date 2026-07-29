import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// =========================
  /// SUMMARY CARDS
  /// =========================

  Future<int> getTotalActiveUsers() async {
    final snapshot = await _firestore
        .collection("users")
        .where("status", isEqualTo: "active")
        .get();

    return snapshot.docs.length;
  }

  Future<int> getTotalVenues() async {
    final snapshot = await _firestore.collection("venues").get();

    return snapshot.docs.length;
  }

  Future<int> getTotalBookings() async {
    final snapshot = await _firestore.collection("bookings").get();

    return snapshot.docs.length;
  }

  Future<double> getTotalRevenue() async {
    final snapshot = await _firestore
        .collection("bookings")
        .where("status", isEqualTo: "completed")
        .get();

    double revenue = 0;

    for (final doc in snapshot.docs) {
      revenue += (doc["totalPrice"] as num).toDouble();
    }

    return revenue;
  }

  /// =========================
  /// BOOKING OVERVIEW
  /// =========================

  Future<Map<String, int>> getBookingOverview() async {
    final snapshot = await _firestore.collection("bookings").get();

    int approved = 0;
    int completed = 0;
    int cancelled = 0;
    int pending = 0;

    for (final doc in snapshot.docs) {
      final status = doc["status"];

      switch (status) {
        case "approved":
          approved++;
          break;

        case "completed":
          completed++;
          break;

        case "cancelled":
          cancelled++;
          break;

        default:
          pending++;
      }
    }

    return {
      "Approved": approved,
      "Completed": completed,
      "Cancelled": cancelled,
      "Pending": pending,
    };
  }

  /// =========================
  /// POPULAR SPORTS
  /// =========================

  Future<Map<String, int>> getPopularSports() async {
    final snapshot = await _firestore.collection("bookings").get();

    final Map<String, int> sports = {};

    for (final doc in snapshot.docs) {
      final sport = doc["sportType"] ?? "Unknown";

      sports[sport] = (sports[sport] ?? 0) + 1;
    }

    return sports;
  }

  /// =========================
  /// PEAK USAGE
  /// =========================

  Future<Map<String, int>> getPeakUsage() async {
    final snapshot = await _firestore.collection("bookings").get();

    int morning = 0;
    int afternoon = 0;
    int evening = 0;
    int night = 0;

    for (final doc in snapshot.docs) {
      final startTime = doc["startTime"];

      if (startTime == null) continue;

      final hour = _extractHour(startTime);

      if (hour >= 6 && hour < 12) {
        morning++;
      } else if (hour >= 12 && hour < 18) {
        afternoon++;
      } else if (hour >= 18 && hour < 24) {
        evening++;
      } else {
        night++;
      }
    }

    return {
      "Morning": morning,
      "Afternoon": afternoon,
      "Evening": evening,
      "Night": night,
    };
  }

  /// =========================
  /// Helper
  /// =========================

  int _extractHour(String time) {
    try {
      return int.parse(time.split(":").first);
    } catch (_) {
      return 0;
    }
  }
}
