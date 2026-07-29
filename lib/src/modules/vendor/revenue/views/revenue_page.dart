import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:playspace_sport_hub_booking_system/src/modules/vendor/revenue/viewModels/revenue_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/confirmation_dialog.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<RevenueViewModel>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RevenueViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Earnings",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          buildWallet(vm),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (vm.wallet == null || vm.wallet!.balance <= 0)
                  ? null
                  : () async {
                      await showDialog(
                        context: context,
                        builder: (_) => ConfirmationDialog(
                          title: "Withdraw Earnings",
                          message:
                              "Withdraw RM ${vm.wallet?.balance.toStringAsFixed(2) ?? "0.00"} to your registered bank account?",
                          confirmButtonText: "Withdraw",
                          cancelButtonText: "Cancel",
                          onConfirm: () async {
                            Navigator.pop(context);

                            try {
                              await vm.withdraw();

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Withdrawal successful."),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );

                              await vm.loadData();
                            }
                          },
                        ),
                      );
                    },
              child: const Text("Withdraw Earnings"),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Payment History",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          buildPaymentHistory(vm),

          const SizedBox(height: 30),

          const Text(
            "Withdrawal History",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          buildWithdrawHistory(vm),

          const SizedBox(height: 30),

          const Text(
            "Monthly Earnings Summary",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          buildMonthlySummary(vm),
        ],
      ),
    );
  }

  Widget buildWallet(RevenueViewModel vm) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Available Balance", style: TextStyle(fontSize: 16)),

            const SizedBox(height: 10),

            Text(
              "RM ${vm.wallet?.balance.toStringAsFixed(2) ?? "0.00"}",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),

            const Divider(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Revenue"),

                Text(
                  "RM ${vm.wallet?.totalRevenue.toStringAsFixed(2) ?? "0.00"}",
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Withdrawn"),

                Text(
                  "RM ${vm.wallet?.totalWithdrawn.toStringAsFixed(2) ?? "0.00"}",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentHistory(RevenueViewModel vm) {
    if (vm.payments.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text("No payment history.")),
        ),
      );
    }

    return Column(
      children: vm.payments.map((booking) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.payments),

            title: Text(booking.venueName),

            subtitle: Text(
              "${booking.bookerName}\n${DateFormat("dd MMM yyyy").format(booking.bookingDate)}",
            ),

            trailing: Text("+RM ${booking.totalPrice.toStringAsFixed(2)}"),
          ),
        );
      }).toList(),
    );
  }

  Widget buildWithdrawHistory(RevenueViewModel vm) {
    if (vm.withdrawals.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text("No withdrawal history.")),
        ),
      );
    }

    return Column(
      children: vm.withdrawals.map((withdraw) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance),

            title: Text(withdraw.bankName),

            subtitle: Text(
              DateFormat(
                "dd MMM yyyy, hh:mm a",
              ).format(DateTime.parse(withdraw.requestedAt)),
            ),

            trailing: Text("-RM ${withdraw.amount.toStringAsFixed(2)}"),
          ),
        );
      }).toList(),
    );
  }

  Widget buildMonthlySummary(RevenueViewModel vm) {
    if (vm.monthlySummary.isEmpty) {
      return const Text("No monthly earnings.");
    }

    return Column(
      children: vm.monthlySummary.map((month) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.bar_chart),
            title: Text(month.month),
            trailing: Text("RM ${month.amount.toStringAsFixed(2)}"),
          ),
        );
      }).toList(),
    );
  }
}
