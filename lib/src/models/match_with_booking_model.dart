import 'package:playspace_sport_hub_booking_system/src/models/booking_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/match_model.dart';

class MatchWithBookingModel {
  final MatchModel match;
  final BookingModel booking;

  MatchWithBookingModel({required this.match, required this.booking});
}
