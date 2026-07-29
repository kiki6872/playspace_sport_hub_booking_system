import 'package:flutter/material.dart';

import 'package:playspace_sport_hub_booking_system/src/models/bank_account_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/profile/services/bank_account_service.dart';

class BankAccountViewModel extends ChangeNotifier {
  final BankAccountService _service = BankAccountService();

  BankAccountModel? account;

  bool isLoading = false;

  Future<void> loadAccount() async {
    isLoading = true;
    notifyListeners();

    account = await _service.getBankAccount();

    isLoading = false;
    notifyListeners();
  }

  Future<void> saveAccount(BankAccountModel data) async {
    await _service.saveBankAccount(data);

    await loadAccount();
  }
}
