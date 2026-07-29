import 'package:flutter/material.dart';

import 'package:playspace_sport_hub_booking_system/src/models/user_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/users/services/users_service.dart';

class UsersViewModel extends ChangeNotifier {
  final UsersService _usersService = UsersService();

  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];

  List<UserModel> get filteredUsers => _filteredUsers;

  List<UserModel> get users => _users;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    _users = await _usersService.getAllUsers();
    _filteredUsers = List.from(_users);

    _isLoading = false;
    notifyListeners();
  }

  void searchUsers(String keyword) {
    if (keyword.isEmpty) {
      _filteredUsers = List.from(_users);
    } else {
      _filteredUsers = _users.where((user) {
        return user.fullName.toLowerCase().contains(keyword.toLowerCase());
      }).toList();
    }

    notifyListeners();
  }

  void filterUsers(String role) {
    if (role == "All") {
      _filteredUsers = List.from(_users);
    } else {
      _filteredUsers = _users.where((user) {
        return user.role.toLowerCase() == role.toLowerCase();
      }).toList();
    }

    notifyListeners();
  }
}
