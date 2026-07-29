class FavoriteModel {
  final String id;
  final String userId;
  final String venueId;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.venueId,
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "venueId": venueId,
    };
  }

  factory FavoriteModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return FavoriteModel(
      id: id,
      userId: map["userId"] ?? "",
      venueId: map["venueId"] ?? "",
    );
  }
}