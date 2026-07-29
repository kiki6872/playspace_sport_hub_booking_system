class PromotionModel {
  final String id;
  final String vendorId;
  final String title;
  final String description;
  final double discountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String status;
  final String applyTo;
  final List<String> venueIds;

  PromotionModel({
    required this.id,
    required this.vendorId,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.status,
    required this.applyTo,

    required this.venueIds,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "vendorId": vendorId,
      "title": title,
      "description": description,
      "discountPercentage": discountPercentage,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
      "isActive": isActive,
      "status": status,
      "applyTo": applyTo,
      "venueIds": venueIds,
    };
  }

  factory PromotionModel.fromMap(Map<String, dynamic> map) {
    return PromotionModel(
      id: map["id"] ?? "",
      vendorId: map["vendorId"] ?? "",
      title: map["title"] ?? "",
      description: map["description"] ?? "",
      discountPercentage: (map["discountPercentage"] ?? 0).toDouble(),
      startDate: map["startDate"] != null
          ? DateTime.parse(map["startDate"])
          : DateTime.now(),
      endDate: map["endDate"] != null
          ? DateTime.parse(map["endDate"])
          : DateTime.now(),
      isActive: map["isActive"] ?? false,
      status: map["status"] ?? "pending",
      applyTo: map["applyTo"] ?? "all",
      venueIds: List<String>.from(map["venueIds"] ?? []),
    );
  }
}
