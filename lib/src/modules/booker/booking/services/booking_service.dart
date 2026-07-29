import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/revenue/services/revenue_service.dart';
import 'package:playspace_sport_hub_booking_system/src/models/booking_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/booking_schedule_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/slot_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/reward/services/reward_service.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createBooking(BookingModel booking) async {
    // Find schedule
    final scheduleQuery = await _firestore
        .collection("booking_schedule")
        .where("venueId", isEqualTo: booking.venueId)
        .where(
          "scheduleDate",
          isEqualTo: DateTime(
            booking.bookingDate.year,
            booking.bookingDate.month,
            booking.bookingDate.day,
          ).toIso8601String(),
        )
        .limit(1)
        .get();

    if (scheduleQuery.docs.isEmpty) {
      throw Exception(
        'No booking_schedule found for venue ${booking.venueId} on ${booking.bookingDate}',
      );
    }

    final scheduleRef = scheduleQuery.docs.first.reference;
    final bookingRef = _firestore.collection('bookings').doc(booking.id);

    // Save booking and mark the slot occupied atomically
    await _firestore.runTransaction((transaction) async {
      final scheduleSnapshot = await transaction.get(scheduleRef);

      final schedule = BookingScheduleModel.fromMap(scheduleSnapshot.data()!);

      final index = schedule.slots.indexWhere(
        (slot) =>
            slot.startTime == booking.startTime &&
            slot.endTime == booking.endTime,
      );

      if (index == -1) {
        throw Exception(
          'No matching slot ${booking.startTime}-${booking.endTime} in schedule ${schedule.id}',
        );
      }

      schedule.slots[index] = SlotModel(
        id: schedule.slots[index].id,
        startTime: schedule.slots[index].startTime,
        endTime: schedule.slots[index].endTime,
        status: "occupied",
      );

      transaction.set(bookingRef, booking.toMap());
      transaction.update(scheduleRef, {
        "slots": schedule.slots.map((e) => e.toMap()).toList(),
      });
    });
  }

  Future<List<BookingModel>> getBookerBookings() async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('bookerId', isEqualTo: _auth.currentUser!.uid)
        .get();

    return snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data()))
        .toList();
  }

  Future<List<BookingModel>> getVendorBookings() async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('vendorId', isEqualTo: _auth.currentUser!.uid)
        .get();

    return snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    final bookingDoc = await _firestore
        .collection('bookings')
        .doc(bookingId)
        .get();

    if (!bookingDoc.exists) return;

    final data = bookingDoc.data()!;

    await _firestore.collection('bookings').doc(bookingId).update({
      'status': status,
    });

    if (status == "completed" && (data["rewardGiven"] ?? false) == false) {
      await _firestore.collection("rewards").doc(data["bookerId"]).update({
        "points": FieldValue.increment((data["totalPrice"] as num).toInt()),
      });

      await _firestore.collection("bookings").doc(bookingId).update({
        "rewardGiven": true,
      });
    }
  }

  Future<void> markBookingAsReviewed(String bookingId) async {
    await _firestore.collection("bookings").doc(bookingId).update({
      "isReviewed": true,
    });
  }

  Future<void> cancelBooking(BookingModel booking) async {
    // 1. Cari schedule
    final scheduleQuery = await _firestore
        .collection("booking_schedule")
        .where("venueId", isEqualTo: booking.venueId)
        .where(
          "scheduleDate",
          isEqualTo: DateTime(
            booking.bookingDate.year,
            booking.bookingDate.month,
            booking.bookingDate.day,
          ).toIso8601String(),
        )
        .limit(1)
        .get();

    if (scheduleQuery.docs.isEmpty) {
      throw Exception(
        'No booking_schedule found for venue ${booking.venueId} on ${booking.bookingDate}',
      );
    }

    final scheduleRef = scheduleQuery.docs.first.reference;
    final bookingRef = _firestore.collection('bookings').doc(booking.id);

    // 2. Update booking status and free the slot atomically
    await _firestore.runTransaction((transaction) async {
      final scheduleSnapshot = await transaction.get(scheduleRef);

      final schedule = BookingScheduleModel.fromMap(scheduleSnapshot.data()!);

      // 3. Cari slot
      final index = schedule.slots.indexWhere(
        (slot) =>
            slot.startTime == booking.startTime &&
            slot.endTime == booking.endTime,
      );

      if (index == -1) {
        throw Exception(
          'No matching slot ${booking.startTime}-${booking.endTime} in schedule ${schedule.id}',
        );
      }

      // 4. Tukar occupied -> available
      schedule.slots[index] = SlotModel(
        id: schedule.slots[index].id,
        startTime: schedule.slots[index].startTime,
        endTime: schedule.slots[index].endTime,
        status: "available",
      );

      transaction.update(bookingRef, {"status": "cancelled"});
      transaction.update(scheduleRef, {
        "slots": schedule.slots.map((e) => e.toMap()).toList(),
      });
    });
  }

  Future<void> autoCompleteBookings() async {
    final uid = _auth.currentUser!.uid;

    final today = DateTime.now();

    final now = DateTime(today.year, today.month, today.day);

    final snapshot = await _firestore
        .collection("bookings")
        .where("bookerId", isEqualTo: uid)
        .where("status", isEqualTo: "approved")
        .get();

    for (final doc in snapshot.docs) {
      final booking = BookingModel.fromMap(doc.data());

      final bookingDate = DateTime(
        booking.bookingDate.year,
        booking.bookingDate.month,
        booking.bookingDate.day,
      );

      if (bookingDate.isBefore(now)) {
        await doc.reference.update({"status": "completed"});

        if (!booking.rewardGiven) {
          final rewardService = RewardService();

          await rewardService.addPoints(
            userId: booking.bookerId,
            points: booking.totalPrice.toInt(),
          );

          await doc.reference.update({"rewardGiven": true});
        }
        if (!booking.revenueAdded) {
          final revenueService = RevenueService();

          await revenueService.addRevenue(
            vendorId: booking.vendorId,
            amount: booking.totalPrice,
          );

          await doc.reference.update({"revenueAdded": true});
        }
      }
    }
  }

  /// Get Upcoming Approved Bookings
  Future<List<BookingModel>> getUpcomingBookings() async {
    final uid = _auth.currentUser!.uid;

    final today = DateTime.now();

    final snapshot = await _firestore
        .collection("bookings")
        .where("bookerId", isEqualTo: uid)
        .where("status", isEqualTo: "approved")
        .get();

    return snapshot.docs.map((e) => BookingModel.fromMap(e.data())).where((
      booking,
    ) {
      final bookingDate = DateTime(
        booking.bookingDate.year,
        booking.bookingDate.month,
        booking.bookingDate.day,
      );

      final currentDate = DateTime(today.year, today.month, today.day);

      return bookingDate.isAtSameMomentAs(currentDate) ||
          bookingDate.isAfter(currentDate);
    }).toList();
  }
}
