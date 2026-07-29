import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:playspace_sport_hub_booking_system/src/models/user_model.dart';

class UsersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();

    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }
}
