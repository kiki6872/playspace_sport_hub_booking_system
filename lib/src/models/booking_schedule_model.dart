import 'slot_model.dart';

class BookingScheduleModel {
  final String id;

  final String vendorId;

  final String venueId;

  final String venueName;

  final DateTime scheduleDate;

  final List<SlotModel> slots;

  BookingScheduleModel({
    required this.id,
    required this.vendorId,
    required this.venueId,
    required this.venueName,
    required this.scheduleDate,
    required this.slots,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "vendorId": vendorId,
      "venueId": venueId,
      "venueName": venueName,
      "scheduleDate": scheduleDate.toIso8601String(),
      "slots": slots.map((e) => e.toMap()).toList(),
    };
  }

  factory BookingScheduleModel.fromMap(Map<String, dynamic> map) {
    return BookingScheduleModel(
      id: map["id"] ?? "",
      vendorId: map["vendorId"] ?? "",
      venueId: map["venueId"] ?? "",
      venueName: map["venueName"] ?? "",
      scheduleDate: DateTime.parse(map["scheduleDate"]),
      slots: (map["slots"] as List<dynamic>)
          .map((e) => SlotModel.fromMap(e))
          .toList(),
    );
  }
}
