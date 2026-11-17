import 'package:flutter/material.dart';
import 'package:playspace_sport_hub_booking_system/src/models/booking_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/booking_schedule_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/slot_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/venue_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/schedule/services/booking_schedule_service.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/venue/services/venue_service.dart';

class BookingScheduleViewModel extends ChangeNotifier {
  final BookingScheduleService _service = BookingScheduleService();
  final VenueService _venueService = VenueService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => _bookings;

  List<VenueModel> _venues = [];
  List<VenueModel> get venues => _venues;

  VenueModel? _selectedVenue;
  VenueModel? get selectedVenue => _selectedVenue;

  BookingScheduleModel? _schedule;
  BookingScheduleModel? get schedule => _schedule;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  SlotModel? _selectedSlot;
  SlotModel? get selectedSlot => _selectedSlot;

  Future<void> loadBookings() async {
    try {
      _isLoading = true;
      notifyListeners();

      _bookings = await _service.getVendorBookings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVendorVenues() async {
    _venues = await _venueService.getVendorVenues();

    if (_venues.isNotEmpty) {
      _selectedVenue = _venues.first;
    }

    notifyListeners();
  }

  void selectVenue(VenueModel venue) {
    _selectedVenue = venue;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void selectSlot(SlotModel slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  Future<void> loadSchedule() async {
    if (_selectedVenue == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _service.createDailySchedule(
        vendorId: _selectedVenue!.vendorId,
        venueId: _selectedVenue!.id,
        venueName: _selectedVenue!.name,
        date: _selectedDate,
      );

      _schedule = await _service.loadSchedule(
        venueId: _selectedVenue!.id,
        date: _selectedDate,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> blockSelectedSlot() async {
    if (_schedule == null || _selectedSlot == null) return;

    await _service.blockSlot(schedule: _schedule!, slotId: _selectedSlot!.id);

    await loadSchedule();
  }

  Future<void> unblockSelectedSlot() async {
    if (_schedule == null || _selectedSlot == null) return;

    await _service.unblockSlot(schedule: _schedule!, slotId: _selectedSlot!.id);

    await loadSchedule();
  }

  Future<void> approveBooking(String bookingId) async {
    await _service.updateStatus(bookingId, "approved");

    await loadBookings();
  }

  Future<void> rejectBooking(String bookingId) async {
    await _service.updateStatus(bookingId, "rejected");

    await loadBookings();
  }
}
