import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  Map<String, dynamic> profile = {};
  String get fullName => profile["fullName"] ?? "";
  String get profileImage => profile["profileImage"] ?? "";
  String get email => profile["email"] ?? "";
  String get phone => profile["phone"] ?? "";
  bool isLoading = false;

  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();
    profile = await _service.getProfile();
    print("UID: ${FirebaseAuth.instance.currentUser?.uid}");
    print("NAME: ${profile["fullName"]}");
    print("EMAIL: ${profile["email"]}");
    isLoading = false;
    notifyListeners();
  }

  Future<void> save({
    required String fullName,
    required String phoneNumber,
  }) async {
    await _service.updateProfile(fullName: fullName, phoneNumber: phoneNumber);
    await loadProfile();
  }

  Future<void> updateProfileImage(String imageUrl) async {
    await _service.updateProfileImage(imageUrl);
    await loadProfile();
  }

  void clear() {
    profile = {};
    notifyListeners();
  }
}
