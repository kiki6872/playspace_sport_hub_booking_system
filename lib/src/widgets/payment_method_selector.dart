import 'package:flutter/material.dart';

class PaymentMethodSelector extends StatelessWidget {
  final String paymentMethod;

  final ValueChanged<String> onChanged;

  const PaymentMethodSelector({
    super.key,
    required this.paymentMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Method",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),

        Card(
          child: RadioListTile<String>(
            value: "equally",
            groupValue: paymentMethod,
            onChanged: (value) => onChanged(value!),
            title: const Text("Equally"),
            subtitle: const Text(
              "Everyone shares the booking cost equally.\n"
              "The amount per person decreases as more players join.",
            ),
          ),
        ),

        const SizedBox(height: 10),

        Card(
          child: RadioListTile<String>(
            value: "host",
            groupValue: paymentMethod,
            onChanged: (value) => onChanged(value!),
            title: const Text("Host Pays"),
            subtitle: const Text(
              "The host pays the full booking fee.\n"
              "All participants join for FREE.",
            ),
          ),
        ),
      ],
    );
  }
}
