import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:playspace_sport_hub_booking_system/src/models/user_model.dart';

import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/services/auth_service.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/services/user_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  final TextEditingController fullNameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  bool get isLoading {
    return _isLoading;
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String? validateRegister() {
    if (fullNameController.text.trim().isEmpty) {
      return 'Please enter your full name.';
    }

    if (emailController.text.trim().isEmpty) {
      return 'Please enter your email.';
    }

    if (phoneController.text.trim().isEmpty) {
      return 'Please enter your phone number.';
    }

    if (passwordController.text.trim().isEmpty) {
      return 'Please enter your password.';
    }

    if (passwordController.text.trim().length < 6) {
      return 'Password must be at least 6 characters.';
    }

    if (confirmPasswordController.text.trim().isEmpty) {
      return 'Please confirm your password.';
    }

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      return 'Passwords do not match.';
    }

    return null;
  }

  Future<String?> register() async {
    final validation = validateRegister();

    if (validation != null) {
      return validation;
    }

    try {
      setLoading(true);

      final credential = await _authService.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = UserModel(
        uid: credential.user!.uid,
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        role: 'booker',
        status: 'active',
        profileImage: "",
      );

      await _userService.createUser(user);

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered.';

        case 'invalid-email':
          return 'Please enter a valid email address.';

        case 'weak-password':
          return 'Password is too weak.';

        default:
          return e.message ?? 'Registration failed.';
      }
    } catch (e, stackTrace) {
      debugPrint('Register Error: $e');
      debugPrint(stackTrace.toString());

      return e.toString();
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }
}
