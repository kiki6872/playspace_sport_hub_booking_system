import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:playspace_sport_hub_booking_system/src/models/bank_account_model.dart';

class BankAccountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<BankAccountModel> getBankAccount() async {
    final uid = _auth.currentUser!.uid;

    final doc = await _firestore.collection("users").doc(uid).get();

    return BankAccountModel.fromMap(doc.data() ?? {});
  }

  Future<void> saveBankAccount(BankAccountModel account) async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection("users").doc(uid).update(account.toMap());
  }
}
