class RewardModel {
  final String userId;
  final int points;

  RewardModel({required this.userId, required this.points});

  Map<String, dynamic> toMap() {
    return {"userId": userId, "points": points};
  }

  factory RewardModel.fromMap(Map<String, dynamic> map) {
    return RewardModel(userId: map["userId"] ?? "", points: map["points"] ?? 0);
  }
}
