import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playspace_sport_hub_booking_system/src/models/booking_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/match_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/match_with_booking_model.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ==========================
  /// CREATE MATCH
  /// ==========================

  Future<void> createMatch(MatchModel match) async {
    await _firestore
        .collection("matches")
        .doc(match.matchId)
        .set(match.toMap());
  }

  /// ==========================
  /// GET AVAILABLE MATCHES
  /// ==========================

  Future<List<MatchWithBookingModel>> getOpenMatches() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("matches")
        .orderBy("createdAt", descending: true)
        .get();

    List<MatchWithBookingModel> result = [];

    for (final doc in snapshot.docs) {
      final match = MatchModel.fromMap(doc.data());

      if (match.hostId == uid) continue;

      if (!(match.status == "waiting" || match.status == "ready")) continue;

      final booking = await _getBooking(match.bookingId);

      result.add(MatchWithBookingModel(match: match, booking: booking));
    }

    return result;
  }

  /// ==========================
  /// MY MATCHES
  /// ==========================

  Future<List<MatchWithBookingModel>> getMyMatches() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("matches")
        .where("hostId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .get();

    List<MatchWithBookingModel> result = [];

    for (final doc in snapshot.docs) {
      final match = MatchModel.fromMap(doc.data());

      final booking = await _getBooking(match.bookingId);

      result.add(MatchWithBookingModel(match: match, booking: booking));
    }

    return result;
  }

  /// ==========================
  /// JOIN MATCH
  /// ==========================

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

  /// ==========================
  /// LEAVE MATCH
  /// ==========================

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

  /// ==========================
  /// DELETE MATCH
  /// ==========================

  Future<void> deleteMatch(String id) async {
    await _firestore.collection("matches").doc(id).delete();
  }

  /// ==========================
  /// CLOSE MATCH
  /// ==========================

  Future<void> closeMatch(String id) async {
    await _firestore.collection("matches").doc(id).update({
      "status": "completed",
    });
  }

  Future<BookingModel> _getBooking(String bookingId) async {
    final doc = await _firestore.collection("bookings").doc(bookingId).get();

    if (!doc.exists) {
      throw Exception("Booking not found.");
    }

    return BookingModel.fromMap(doc.data()!);
  }
}
