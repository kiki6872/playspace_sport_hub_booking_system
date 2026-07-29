import 'package:flutter/material.dart';

import 'package:playspace_sport_hub_booking_system/src/models/booking_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/booking/services/booking_service.dart';

class BookingViewModel extends ChangeNotifier {
  final BookingService _bookingService = BookingService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => _bookings;

  Future<void> loadBookerBookings() async {
    _isLoading = true;
    notifyListeners();

    await _bookingService.autoCompleteBookings();

    _bookings = await _bookingService.getBookerBookings();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createBooking(BookingModel booking) async {
    _isLoading = true;
    notifyListeners();

    await _bookingService.createBooking(booking);

    _isLoading = false;
    notifyListeners();

    await loadBookerBookings();
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _bookingService.updateBookingStatus(bookingId, status);

    await loadBookerBookings();
  }

  Future<void> cancelBooking(BookingModel booking) async {
    _isLoading = true;
    notifyListeners();

    await _bookingService.cancelBooking(booking);

    _isLoading = false;
    notifyListeners();

    await loadBookerBookings();
  }

  Future<void> markBookingAsReviewed(String bookingId) async {
    await _bookingService.markBookingAsReviewed(bookingId);

    await loadBookerBookings();
  }
}
