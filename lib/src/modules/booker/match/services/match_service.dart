import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playspace_sport_hub_booking_system/src/models/booking_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/match_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/match_with_booking_model.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createMatch(MatchModel match) async {
    await _firestore
        .collection("matches")
        .doc(match.matchId)
        .set(match.toMap());
  }

  Future<List<MatchWithBookingModel>> getOpenMatches() async {
    final uid = _auth.currentUser!.uid;

    // Sorted client-side rather than via .orderBy() so doesn't need a composite index (whereIn + orderBy on a different field)
    final snapshot = await _firestore
        .collection("matches")
        .where("status", whereIn: ["waiting", "ready"])
        .get();

    final matches = snapshot.docs
        .map((doc) => MatchModel.fromMap(doc.data()))
        .where((match) => match.hostId != uid)
        .toList();

    matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return _attachBookings(matches);
  }

  Future<List<MatchWithBookingModel>> getMyMatches() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("matches")
        .where("hostId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .get();

    final matches = snapshot.docs
        .map((doc) => MatchModel.fromMap(doc.data()))
        .toList();

    return _attachBookings(matches);
  }

  /// Fetches each match's booking in parallel (rather than one Firestore round-trip at a time) and silently drops any match whose bookingId no longer resolves to a real booking
  Future<List<MatchWithBookingModel>> _attachBookings(
    List<MatchModel> matches,
  ) async {
    final results = await Future.wait(
      matches.map((match) async {
        final booking = await _tryGetBooking(match.bookingId);

        if (booking == null) return null;

        return MatchWithBookingModel(match: match, booking: booking);
      }),
    );

    return results.whereType<MatchWithBookingModel>().toList();
  }

  Future<void> joinMatch(MatchModel match) async {
    final uid = _auth.currentUser!.uid;

    if (match.participants.any((e) => e["userId"] == uid)) {
      return;
    }

    final userDoc = await _firestore.collection("users").doc(uid).get();
    final participants = List<Map<String, dynamic>>.from(match.participants);
    participants.add({"userId": uid, "userName": userDoc["fullName"]});
    final currentPlayers = participants.length;
    final booking = await _getBooking(match.bookingId);
    final double currentPrice = match.paymentMethod == "host"
        ? 0
        : booking.totalPrice / currentPlayers;

    String status = "waiting";

    if (currentPlayers >= match.maximumPlayers) {
      status = "full";
    } else if (currentPlayers >= 2) {
      status = "ready";
    }

    await _firestore.collection("matches").doc(match.matchId).update({
      "participants": participants,
      "currentPlayers": currentPlayers,
      "currentPricePerPerson": currentPrice,
      "status": status,
    });
  }

  Future<void> leaveMatch(MatchModel match) async {
    final uid = _auth.currentUser!.uid;
    final participants = List<Map<String, dynamic>>.from(match.participants);
    participants.removeWhere((e) => e["userId"] == uid);
    final currentPlayers = participants.length;
    final booking = await _getBooking(match.bookingId);
    final double currentPrice = currentPlayers == 0
        ? booking.totalPrice
        : match.paymentMethod == "host"
        ? 0
        : booking.totalPrice / currentPlayers;

    String status = "waiting";
    if (currentPlayers >= match.maximumPlayers) {
      status = "full";
    } else if (currentPlayers >= 2) {
      status = "ready";
    }
    await _firestore.collection("matches").doc(match.matchId).update({
      "participants": participants,
      "currentPlayers": currentPlayers,
      "currentPricePerPerson": currentPrice,
      "status": status,
    });
  }

  Future<void> deleteMatch(String id) async {
    await _firestore.collection("matches").doc(id).delete();
  }

  Future<void> closeMatch(String id) async {
    await _firestore.collection("matches").doc(id).update({
      "status": "completed",
    });
  }

  Future<BookingModel> _getBooking(String bookingId) async {
    final booking = await _tryGetBooking(bookingId);

    if (booking == null) {
      throw Exception("Booking not found.");
    }

    return booking;
  }

  Future<BookingModel?> _tryGetBooking(String bookingId) async {
    final doc = await _firestore.collection("bookings").doc(bookingId).get();

    if (!doc.exists) return null;

    return BookingModel.fromMap(doc.data()!);
  }
}
