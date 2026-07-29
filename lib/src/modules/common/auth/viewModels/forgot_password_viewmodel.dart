import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/services/auth_service.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();

  bool _isLoading = false;

  bool get isLoading {
    return _isLoading;
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String? validateEmail() {
    if (emailController.text.trim().isEmpty) {
      return 'Please enter your email.';
    }

    return null;
  }

  Future<String?> resetPassword() async {
    final validation = validateEmail();

    if (validation != null) {
      return validation;
    }

    try {
      setLoading(true);

      await _authService.forgotPassword(email: emailController.text.trim());

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email.';

        case 'invalid-email':
          return 'Please enter a valid email address.';

        default:
          return e.message ?? 'Failed to send reset email.';
      }
    } catch (e) {
      return 'An unexpected error occurred.';
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
