import 'package:flutter/material.dart';

import 'package:playspace_sport_hub_booking_system/src/models/booking_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/vendor_wallet_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/withdrawal_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/monthly_earning_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/revenue/services/revenue_service.dart';

class RevenueViewModel extends ChangeNotifier {
  final RevenueService _service = RevenueService();

  VendorWalletModel? wallet;

  List<BookingModel> payments = [];

  List<WithdrawalModel> withdrawals = [];
  List<MonthlyEarningModel> monthlySummary = [];

  bool isLoading = false;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    wallet = await _service.getWallet();

    payments = await _service.getPaymentHistory();

    withdrawals = await _service.getWithdrawHistory();
    monthlySummary = await _service.getMonthlySummary();

    isLoading = false;
    notifyListeners();
  }

  Future<void> withdraw() async {
    if (wallet == null) return;

    await _service.withdraw(amount: wallet!.balance);

    await loadData();
  }
}
