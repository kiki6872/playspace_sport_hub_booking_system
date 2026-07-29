class BookingModel {
  final String id;

  final String venueId;
  final String venueName;

  final String vendorId;

  final String bookerId;
  final String bookerName;

  final String sportType;
  final String bookingType;

  final DateTime bookingDate;

  final String startTime;
  final String endTime;

  final double totalPrice;

  final String status;
  final bool isReviewed;
  final bool rewardGiven;
  final bool revenueAdded;
  final String promotionId;

  BookingModel({
    required this.id,
    required this.venueId,
    required this.venueName,
    required this.vendorId,
    required this.bookerId,
    required this.bookerName,
    required this.sportType,
    required this.bookingType,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    required this.isReviewed,
    required this.rewardGiven,
    required this.revenueAdded,
    this.promotionId = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'venueId': venueId,
      'venueName': venueName,
      'vendorId': vendorId,
      'bookerId': bookerId,
      'bookerName': bookerName,
      'sportType': sportType,
      "bookingType": bookingType,
      'bookingDate': bookingDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'totalPrice': totalPrice,
      'status': status,
      'isReviewed': isReviewed,
      'rewardGiven': rewardGiven,
      'revenueAdded': revenueAdded,
      'promotionId': promotionId,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      venueId: map['venueId'] ?? '',
      venueName: map['venueName'] ?? '',
      vendorId: map['vendorId'] ?? '',
      bookerId: map['bookerId'] ?? '',
      bookerName: map['bookerName'] ?? '',
      sportType: map['sportType'] ?? '',
      bookingType: map["bookingType"] ?? "own",
      bookingDate: DateTime.parse(map['bookingDate']),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      isReviewed: map['isReviewed'] ?? false,
      rewardGiven: map['rewardGiven'] ?? false,
      revenueAdded: map["revenueAdded"] ?? false,
      promotionId: map["promotionId"] ?? "",
    );
  }
}
