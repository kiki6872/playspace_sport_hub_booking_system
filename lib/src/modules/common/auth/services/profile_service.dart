import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> getProfile() async {
    final uid = _auth.currentUser!.uid;

    final doc = await _firestore.collection("users").doc(uid).get();

    return doc.data() ?? {};
  }

  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection("users").doc(uid).update({
      "fullName": fullName,
      "phone": phoneNumber,
    });
  }

  Future<void> updateProfileImage(String imageUrl) async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection("users").doc(uid).update({
      "profileImage": imageUrl,
    });
  }
}
