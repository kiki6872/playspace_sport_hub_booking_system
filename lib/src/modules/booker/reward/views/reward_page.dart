import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:playspace_sport_hub_booking_system/src/modules/booker/reward/viewModels/reward_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/reward_card.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  int selectedVoucherTab = 0;
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<RewardViewModel>().loadReward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RewardViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("My Rewards")),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    buildPointCard(vm),

                    const SizedBox(height: 20),

                    const TabBar(
                      tabs: [
                        Tab(text: "To Redeem"),
                        Tab(text: "My Voucher"),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: TabBarView(
                        children: [buildRewardList(vm), buildVoucherPage()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildPointCard(RewardViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xffb6ff00), Color(0xff89d000)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Current Points", style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Text(
            "${vm.reward?.points ?? 0}",
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Text(
            "Keep booking to earn rewards!",
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget buildRewardList(RewardViewModel vm) {
    return ListView(
      children: [
        RewardCard(
          title: "RM5 Voucher",
          points: 100,
          description: "RM5 off your next booking.",
          onRedeem: () => redeem(vm, "RM5 Voucher", 100, 5),
        ),

        RewardCard(
          title: "RM10 Voucher",
          points: 200,
          description: "RM10 off your next booking.",
          onRedeem: () => redeem(vm, "RM10 Voucher", 200, 10),
        ),

        RewardCard(
          title: "RM20 Voucher",
          points: 400,
          description: "RM20 off your next booking.",
          onRedeem: () => redeem(vm, "RM20 Voucher", 400, 20),
        ),

        RewardCard(
          title: "RM50 Voucher",
          points: 1000,
          description: "RM50 off your next booking.",
          onRedeem: () => redeem(vm, "RM50 Voucher", 1000, 50),
        ),
      ],
    );
  }

  Future<void> redeem(
    RewardViewModel vm,
    String title,
    int points,
    int discount,
  ) async {
    try {
      await vm.redeemVoucher(
        title: title,
        requiredPoints: points,
        discount: discount,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("$title redeemed successfully.")));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget buildVoucherPage() {
    final vm = context.watch<RewardViewModel>();

    List vouchers;

    switch (selectedVoucherTab) {
      case 1:
        vouchers = vm.usedVouchers;
        break;

      case 2:
        vouchers = vm.expiredVouchers;
        break;

      default:
        vouchers = vm.activeVouchers;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildChip("Active", vm.activeVouchers.length, 0),

            buildChip("Used", vm.usedVouchers.length, 1),

            buildChip("Expired", vm.expiredVouchers.length, 2),
          ],
        ),

        const SizedBox(height: 25),

        Expanded(
          child: vouchers.isEmpty
              ? const Center(
                  child: Text(
                    "No Data Available",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: vouchers.length,
                  itemBuilder: (_, index) {
                    final voucher = vouchers[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.card_giftcard, color: Colors.white),
                        ),

                        title: Text(voucher.title),

                        subtitle: Text("RM${voucher.discount} Discount"),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget buildChip(String title, int count, int index) {
    final selected = selectedVoucherTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedVoucherTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.orange),
          color: selected ? Colors.orange : Colors.transparent,
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(width: 8),

            CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white,
              child: Text(
                "$count",
                style: const TextStyle(fontSize: 11, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
