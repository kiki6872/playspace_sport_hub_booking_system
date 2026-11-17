import 'package:flutter/material.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playspace_sport_hub_booking_system/src/models/user_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/services/user_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

  bool get isLoading {
    return _isLoading;
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String? validateLogin() {
    if (emailController.text.trim().isEmpty) {
      return 'Please enter your email.';
    }

    if (passwordController.text.trim().isEmpty) {
      return 'Please enter your password.';
    }

    if (passwordController.text.trim().length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }

  Future<String?> login() async {
    final validation = validateLogin();

    if (validation != null) {
      return validation;
    }

    try {
      setLoading(true);

      final credential = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final UserModel? user = await _userService.getUser(credential.user!.uid);

      if (user == null) {
        return 'User profile not found.';
      }

      if (user.status != 'active') {
        await _authService.logout();
        return 'Your account has been suspended. Please contact support.';
      }

      return user.role;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';

        case 'wrong-password':
          return 'Incorrect password.';

        case 'invalid-credential':
          return 'Invalid email or password.';

        case 'invalid-email':
          return 'Please enter a valid email address.';

        case 'too-many-requests':
          return 'Too many login attempts. Please try again later.';

        default:
          return e.message ?? 'Login failed.';
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
    passwordController.dispose();
    super.dispose();
  }
}
