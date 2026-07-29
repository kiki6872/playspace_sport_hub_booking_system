import 'package:flutter/material.dart';
import 'package:playspace_sport_hub_booking_system/src/models/user_voucher_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/reward_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/reward/services/reward_service.dart';

class RewardViewModel extends ChangeNotifier {
  final RewardService _rewardService = RewardService();

  RewardModel? reward;
  List<UserVoucherModel> vouchers = [];
  List<UserVoucherModel> get activeVouchers =>
      vouchers.where((v) => v.status == "active").toList();

  List<UserVoucherModel> get usedVouchers =>
      vouchers.where((v) => v.status == "used").toList();

  List<UserVoucherModel> get expiredVouchers =>
      vouchers.where((v) => v.status == "expired").toList();

  bool isLoading = false;

  Future<void> loadReward() async {
    try {
      print("Load reward start");

      isLoading = true;
      notifyListeners();

      reward = await _rewardService.getReward();
      await loadVouchers();

      print("Reward loaded: ${reward?.points}");
    } catch (e) {
      print("Reward Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();

      print("Load reward end");
    }
  }

  Future<void> addPoints(int points) async {
    await _rewardService.addPoints(userId: reward!.userId, points: points);

    await loadReward();
  }

  Future<void> deductPoints(int points) async {
    await _rewardService.deductPoints(userId: reward!.userId, points: points);
    await loadReward();
  }

  Future<void> redeemVoucher({
    required String title,
    required int requiredPoints,
    required int discount,
  }) async {
    await _rewardService.redeemVoucher(
      title: title,
      requiredPoints: requiredPoints,
      discount: discount,
    );

    await loadReward();
  }

  Future<void> loadVouchers() async {
    vouchers = await _rewardService.getUserVouchers();
    notifyListeners();
  }
}
