class SlotModel {
  final String id;
  final String startTime;
  final String endTime;
  final String status;

  SlotModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "startTime": startTime,
      "endTime": endTime,
      "status": status,
    };
  }

  factory SlotModel.fromMap(Map<String, dynamic> map) {
    return SlotModel(
      id: map["id"] ?? "",
      startTime: map["startTime"] ?? "",
      endTime: map["endTime"] ?? "",
      status: map["status"] ?? "available",
    );
  }
}
