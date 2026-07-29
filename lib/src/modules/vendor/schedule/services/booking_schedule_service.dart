import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import 'package:playspace_sport_hub_booking_system/src/models/booking_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/booking_schedule_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/slot_model.dart';

class BookingScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  ///====================================================
  /// BOOKING
  ///====================================================

  Future<List<BookingModel>> getVendorBookings() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("bookings")
        .where("vendorId", isEqualTo: uid)
        .orderBy("bookingDate")
        .get();

    return snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> updateStatus(String bookingId, String status) async {
    await _firestore.collection("bookings").doc(bookingId).update({
      "status": status,
    });
  }

  ///====================================================
  /// CREATE DAILY SCHEDULE
  ///====================================================

  Future<void> createDailySchedule({
    required String vendorId,
    required String venueId,
    required String venueName,
    required DateTime date,
  }) async {
    try {
      print("===== CREATE SCHEDULE =====");

      final snapshot = await _firestore
          .collection("booking_schedule")
          .where("venueId", isEqualTo: venueId)
          .where("scheduleDate", isEqualTo: date.toIso8601String())
          .limit(1)
          .get();

      print("Existing: ${snapshot.docs.length}");

      if (snapshot.docs.isNotEmpty) {
        print("Already exists");
        return;
      }

      final schedule = BookingScheduleModel(
        id: const Uuid().v4(),
        vendorId: vendorId,
        venueId: venueId,
        venueName: venueName,
        scheduleDate: DateTime(date.year, date.month, date.day),
        slots: generateDefaultSlots(),
      );

      print("Saving schedule...");

      await _firestore
          .collection("booking_schedule")
          .doc(schedule.id)
          .set(schedule.toMap());

      print("SUCCESS");
    } catch (e) {
      print("ERROR: $e");
    }
  }

  ///====================================================
  /// LOAD SCHEDULE
  ///====================================================

  Future<BookingScheduleModel?> loadSchedule({
    required String venueId,
    required DateTime date,
  }) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    try {
      print("Loading schedule...");
      print("Venue: $venueId");
      print("Date: ${date.toIso8601String()}");

      final snapshot = await _firestore
          .collection("booking_schedule")
          .where("venueId", isEqualTo: venueId)
          .where("scheduleDate", isEqualTo: normalizedDate.toIso8601String())
          .limit(1)
          .get();

      print("Documents found: ${snapshot.docs.length}");

      if (snapshot.docs.isEmpty) {
        print("No schedule found");
        return null;
      }

      print(snapshot.docs.first.data());

      return BookingScheduleModel.fromMap(snapshot.docs.first.data());
    } catch (e) {
      print("ERROR: $e");
      rethrow;
    }
  }

  ///====================================================
  /// UPDATE SLOT STATUS
  ///====================================================

  Future<void> updateSlotStatus({
    required BookingScheduleModel schedule,
    required String slotId,
    required String status,
  }) async {
    final index = schedule.slots.indexWhere((slot) => slot.id == slotId);

    if (index == -1) return;

    schedule.slots[index] = SlotModel(
      id: schedule.slots[index].id,
      startTime: schedule.slots[index].startTime,
      endTime: schedule.slots[index].endTime,
      status: status,
    );

    await _firestore.collection("booking_schedule").doc(schedule.id).update({
      "slots": schedule.slots.map((slot) => slot.toMap()).toList(),
    });
  }

  ///====================================================
  /// BLOCK SLOT
  ///====================================================

  Future<void> blockSlot({
    required BookingScheduleModel schedule,
    required String slotId,
  }) async {
    await updateSlotStatus(
      schedule: schedule,
      slotId: slotId,
      status: "blocked",
    );
  }

  ///====================================================
  /// UNBLOCK SLOT
  ///====================================================

  Future<void> unblockSlot({
    required BookingScheduleModel schedule,
    required String slotId,
  }) async {
    await updateSlotStatus(
      schedule: schedule,
      slotId: slotId,
      status: "available",
    );
  }

  Future<void> occupySlot({
    required BookingScheduleModel schedule,
    required String slotId,
  }) async {
    final index = schedule.slots.indexWhere((slot) => slot.id == slotId);

    if (index == -1) return;

    schedule.slots[index] = SlotModel(
      id: schedule.slots[index].id,
      startTime: schedule.slots[index].startTime,
      endTime: schedule.slots[index].endTime,
      status: "occupied",
    );

    await _firestore.collection("booking_schedule").doc(schedule.id).update({
      "slots": schedule.slots.map((e) => e.toMap()).toList(),
    });
  }

  ///====================================================
  /// BOOK SLOT
  ///====================================================

  Future<void> bookSlot({
    required BookingScheduleModel schedule,
    required String slotId,
  }) async {
    await updateSlotStatus(
      schedule: schedule,
      slotId: slotId,
      status: "booked",
    );
  }

  ///====================================================
  /// RELEASE SLOT
  ///====================================================

  Future<void> releaseSlot({
    required BookingScheduleModel schedule,
    required String slotId,
  }) async {
    await updateSlotStatus(
      schedule: schedule,
      slotId: slotId,
      status: "available",
    );
  }

  ///====================================================
  /// DEFAULT SLOT
  ///====================================================

  List<SlotModel> generateDefaultSlots() {
    return [
      SlotModel(
        id: "1",
        startTime: "09:00",
        endTime: "10:00",
        status: "available",
      ),

      SlotModel(
        id: "2",
        startTime: "10:00",
        endTime: "11:00",
        status: "available",
      ),

      SlotModel(
        id: "3",
        startTime: "11:00",
        endTime: "12:00",
        status: "available",
      ),

      SlotModel(
        id: "4",
        startTime: "12:00",
        endTime: "13:00",
        status: "available",
      ),

      SlotModel(
        id: "5",
        startTime: "13:00",
        endTime: "14:00",
        status: "available",
      ),

      SlotModel(
        id: "6",
        startTime: "14:00",
        endTime: "15:00",
        status: "available",
      ),

      SlotModel(
        id: "7",
        startTime: "15:00",
        endTime: "16:00",
        status: "available",
      ),

      SlotModel(
        id: "8",
        startTime: "16:00",
        endTime: "17:00",
        status: "available",
      ),

      SlotModel(
        id: "9",
        startTime: "17:00",
        endTime: "18:00",
        status: "available",
      ),
    ];
  }
}
