import 'package:flutter/material.dart';
import 'package:playspace_sport_hub_booking_system/src/models/user_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/services/user_service.dart';

class UserDetailsViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  late UserModel _user;

  UserModel get user => _user;

  String _selectedRole = '';

  String get selectedRole => _selectedRole;

  void initialize(UserModel user) {
    _user = user;
    _selectedRole = user.role;
  }

  void changeRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  Future<void> saveRole() async {
    await _userService.updateUserRole(uid: _user.uid, role: _selectedRole);

    _user = UserModel(
      uid: _user.uid,
      fullName: _user.fullName,
      email: _user.email,
      phone: _user.phone,
      role: _selectedRole,
      status: _user.status,
      profileImage: _user.profileImage,
    );

    notifyListeners();
  }

  Future<void> toggleUserStatus() async {
    final newStatus = _user.status == "active" ? "suspended" : "active";

    await _userService.updateUserStatus(uid: _user.uid, status: newStatus);

    _user = UserModel(
      uid: _user.uid,
      fullName: _user.fullName,
      email: _user.email,
      phone: _user.phone,
      role: _user.role,
      status: newStatus,
      profileImage: _user.profileImage,
    );

    notifyListeners();
  }

  Future<void> deleteUser() async {
    await _userService.deleteUser(_user.uid);
  }
}
