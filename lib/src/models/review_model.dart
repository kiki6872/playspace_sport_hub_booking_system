class ReviewModel {
  final String id;

  final String venueId;
  final String venueName;

  final String vendorId;

  final String bookerId;
  final String bookerName;

  final double rating;

  final String comment;

  final DateTime createdAt;

  final String reply;

  ReviewModel({
    required this.id,
    required this.venueId,
    required this.venueName,
    required this.vendorId,
    required this.bookerId,
    required this.bookerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.reply,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "venueId": venueId,
      "venueName": venueName,
      "vendorId": vendorId,
      "bookerId": bookerId,
      "bookerName": bookerName,
      "rating": rating,
      "comment": comment,
      "createdAt": createdAt.toIso8601String(),
      "reply": reply,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map["id"] ?? "",
      venueId: map["venueId"] ?? "",
      venueName: map["venueName"] ?? "",
      vendorId: map["vendorId"] ?? "",
      bookerId: map["bookerId"] ?? "",
      bookerName: map["bookerName"] ?? "",
      rating: (map["rating"] ?? 0).toDouble(),
      comment: map["comment"] ?? "",
      createdAt: DateTime.parse(map["createdAt"]),
      reply: map["reply"] ?? "",
    );
  }
}
