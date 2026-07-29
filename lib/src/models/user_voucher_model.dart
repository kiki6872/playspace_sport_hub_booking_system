class UserVoucherModel {
  final String id;
  final String userId;
  final String title;
  final int discount;
  final String status;
  final DateTime redeemedAt;

  UserVoucherModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.discount,
    required this.status,
    required this.redeemedAt,
  });

  factory UserVoucherModel.fromMap(Map<String, dynamic> map) {
    return UserVoucherModel(
      id: map["id"] ?? "",
      userId: map["userId"] ?? "",
      title: map["title"] ?? "",
      discount: map["discount"] ?? 0,
      status: map["status"] ?? "active",
      redeemedAt: DateTime.parse(map["redeemedAt"]),
    );
  }
}
