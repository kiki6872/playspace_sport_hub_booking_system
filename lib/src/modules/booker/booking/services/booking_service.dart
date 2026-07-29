import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/revenue/services/revenue_service.dart';
import 'package:playspace_sport_hub_booking_system/src/models/booking_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/booking_schedule_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/slot_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/reward/services/reward_service.dart';
import 'package:playspace_sport_hub_booking_system/src/models/promotion_model.dart';

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

    // Bookings are auto-approved with no vendor review step, so the vendor
    // is paid as soon as the booking is made rather than waiting for
    // autoCompleteBookings() to run once the booking date passes.
    await RevenueService().addRevenue(
      vendorId: booking.vendorId,
      amount: booking.totalPrice,
    );

    await bookingRef.update({"revenueAdded": true});
  }

  /// Finds the best matching active, admin-approved promotion for this
  /// venue/vendor on the given booking date (highest discount wins if more
  /// than one applies). Returns null if none apply.
  Future<PromotionModel?> getApplicablePromotion({
    required String vendorId,
    required String venueId,
    required DateTime date,
  }) async {
    final snapshot = await _firestore
        .collection("promotions")
        .where("vendorId", isEqualTo: vendorId)
        .where("status", isEqualTo: "approved")
        .where("isActive", isEqualTo: true)
        .get();

    final day = DateTime(date.year, date.month, date.day);

    final matching = snapshot.docs
        .map((doc) => PromotionModel.fromMap(doc.data()))
        .where((promotion) {
          final start = DateTime(
            promotion.startDate.year,
            promotion.startDate.month,
            promotion.startDate.day,
          );
          final end = DateTime(
            promotion.endDate.year,
            promotion.endDate.month,
            promotion.endDate.day,
          );

          final inRange =
              !day.isBefore(start) && !day.isAfter(end);
          final appliesToVenue =
              promotion.applyTo == "all" ||
              promotion.venueIds.contains(venueId);

          return inRange && appliesToVenue;
        })
        .toList();

    if (matching.isEmpty) return null;

    matching.sort(
      (a, b) => b.discountPercentage.compareTo(a.discountPercentage),
    );

    return matching.first;
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
    final bookingRef = _firestore.collection('bookings').doc(bookingId);

    await _firestore.runTransaction((transaction) async {
      final bookingDoc = await transaction.get(bookingRef);

      if (!bookingDoc.exists) {
        throw Exception('Booking $bookingId not found.');
      }

      final data = bookingDoc.data()!;

      transaction.update(bookingRef, {'status': status});

      if (status == "completed" && (data["rewardGiven"] ?? false) == false) {
        final rewardRef = _firestore
            .collection("rewards")
            .doc(data["bookerId"]);

        transaction.update(rewardRef, {
          "points": FieldValue.increment((data["totalPrice"] as num).toInt()),
        });

        transaction.update(bookingRef, {"rewardGiven": true});
      }
    });
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

    var reverseAmount = 0.0;
    var reverseVendorId = '';

    // 2. Update booking status and free the slot atomically
    await _firestore.runTransaction((transaction) async {
      final bookingSnapshot = await transaction.get(bookingRef);

      if (!bookingSnapshot.exists) {
        throw Exception('Booking ${booking.id} not found.');
      }

      final freshBooking = BookingModel.fromMap(bookingSnapshot.data()!);

      if (freshBooking.status == "cancelled" ||
          freshBooking.status == "completed") {
        throw Exception(
          'Booking ${booking.id} cannot be cancelled (status: ${freshBooking.status}).',
        );
      }

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

      final updates = <String, dynamic>{"status": "cancelled"};

      if (freshBooking.revenueAdded) {
        updates["revenueAdded"] = false;
        reverseAmount = freshBooking.totalPrice;
        reverseVendorId = freshBooking.vendorId;
      }

      transaction.update(bookingRef, updates);
      transaction.update(scheduleRef, {
        "slots": schedule.slots.map((e) => e.toMap()).toList(),
      });
    });

    if (reverseVendorId.isNotEmpty) {
      await RevenueService().reverseRevenue(
        vendorId: reverseVendorId,
        amount: reverseAmount,
      );
    }
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
