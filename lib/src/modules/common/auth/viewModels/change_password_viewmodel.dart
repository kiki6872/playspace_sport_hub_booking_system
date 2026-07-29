import 'package:flutter/material.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/services/change_password_service.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final ChangePasswordService _service = ChangePasswordService();

  bool isLoading = false;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
