import 'package:flutter/material.dart';

class PriceInfoCard extends StatelessWidget {
  final double totalPrice;
  final double currentPricePerPerson;
  final String paymentMethod;
  final int currentPlayers;

  const PriceInfoCard({
    super.key,
    required this.totalPrice,
    required this.currentPricePerPerson,
    required this.paymentMethod,
    required this.currentPlayers,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: paymentMethod == "equally"
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Cost",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "RM ${currentPricePerPerson.toStringAsFixed(2)} / Person",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text("Current Players : $currentPlayers"),

                  const SizedBox(height: 8),

                  const Text(
                    "As more players join, the amount per person decreases automatically.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Host Pays",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Host Payment : RM ${totalPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Participants join FREE.",
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
      ),
    );
  }
}
