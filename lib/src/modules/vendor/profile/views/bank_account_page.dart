import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:playspace_sport_hub_booking_system/src/models/bank_account_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/profile/viewModels/bank_account_viewmodel.dart';

class BankAccountPage extends StatefulWidget {
  const BankAccountPage({super.key});

  @override
  State<BankAccountPage> createState() => _BankAccountPageState();
}

class _BankAccountPageState extends State<BankAccountPage> {
  final _formKey = GlobalKey<FormState>();

  final holderController = TextEditingController();
  final accountController = TextEditingController();
  bool autoWithdraw = false;

  String selectedBank = "Maybank";

  final banks = const [
    "Maybank",
    "CIMB Bank",
    "Public Bank",
    "RHB Bank",
    "Hong Leong Bank",
    "Bank Islam",
    "AmBank",
    "BSN",
    "OCBC",
    "UOB",
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final vm = context.read<BankAccountViewModel>();

      await vm.loadAccount();

      final account = vm.account;

      if (account != null) {
        setState(() {
          selectedBank = account.bankName.isEmpty
              ? "Maybank"
              : account.bankName;

          holderController.text = account.accountHolderName;
          accountController.text = account.accountNumber;
          autoWithdraw = account.autoWithdraw;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BankAccountViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Bank Account")),

      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField(
                      value: selectedBank,
                      decoration: const InputDecoration(labelText: "Bank"),
                      items: banks.map((bank) {
                        return DropdownMenuItem(value: bank, child: Text(bank));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBank = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: holderController,
                      decoration: const InputDecoration(
                        labelText: "Account Holder Name",
                      ),
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: accountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Account Number",
                      ),
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 20),

                    SwitchListTile(
                      value: autoWithdraw,
                      title: const Text("Enable Automatic Withdrawal"),
                      subtitle: const Text(
                        "Automatically withdraw on the 25th of every month",
                      ),
                      onChanged: (value) {
                        setState(() {
                          autoWithdraw = value;
                        });
                      },
                    ),
                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          await vm.saveAccount(
                            BankAccountModel(
                              bankName: selectedBank,
                              accountHolderName: holderController.text,
                              accountNumber: accountController.text,

                              autoWithdraw: autoWithdraw,
                              withdrawFrequency: "monthly",
                              withdrawDay: 25,
                            ),
                          );

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Bank account updated."),
                            ),
                          );
                        },
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
