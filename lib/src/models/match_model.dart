import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String matchId;
  final String bookingId;

  /// Host
  final String hostId;
  final String hostName;

  /// Venue

  final double currentPricePerPerson;

  /// equally / host
  final String paymentMethod;

  /// Players

  final int maximumPlayers;
  final int currentPlayers;

  /// Participants
  final List<Map<String, dynamic>> participants;

  /// Match Details
  final String description;

  /// waiting
  /// ready
  /// full
  /// completed
  /// cancelled
  final String status;

  final Timestamp createdAt;

  MatchModel({
    required this.matchId,
    required this.bookingId,
    required this.hostId,
    required this.hostName,

    required this.currentPricePerPerson,
    required this.paymentMethod,

    required this.maximumPlayers,
    required this.currentPlayers,
    required this.participants,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "matchId": matchId,
      "bookingId": bookingId,

      "hostId": hostId,
      "hostName": hostName,

      "currentPricePerPerson": currentPricePerPerson,

      "paymentMethod": paymentMethod,

      "maximumPlayers": maximumPlayers,
      "currentPlayers": currentPlayers,

      "participants": participants,

      "description": description,

      "status": status,

      "createdAt": createdAt,
    };
  }

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
      matchId: map["matchId"] ?? "",
      bookingId: map["bookingId"] ?? "",

      hostId: map["hostId"] ?? "",
      hostName: map["hostName"] ?? "",

      currentPricePerPerson: (map["currentPricePerPerson"] ?? 0).toDouble(),

      paymentMethod: map["paymentMethod"] ?? "equally",

      maximumPlayers: map["maximumPlayers"] ?? 2,

      currentPlayers: map["currentPlayers"] ?? 1,

      participants: List<Map<String, dynamic>>.from(map["participants"] ?? []),

      description: map["description"] ?? "",

      status: map["status"] ?? "waiting",

      createdAt: map["createdAt"] ?? Timestamp.now(),
    );
  }
}
