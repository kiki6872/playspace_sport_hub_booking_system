import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:playspace_sport_hub_booking_system/src/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final document = await _firestore.collection('users').doc(uid).get();

    if (!document.exists) {
      return null;
    }

    return UserModel.fromMap(document.data()!);
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  Future<void> updateUserRole({
    required String uid,
    required String role,
  }) async {
    await _firestore.collection('users').doc(uid).update({'role': role});
  }

  Future<void> updateUserStatus({
    required String uid,
    required String status,
  }) async {
    await _firestore.collection('users').doc(uid).update({'status': status});
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }
}
