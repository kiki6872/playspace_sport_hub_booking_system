import 'package:flutter/material.dart';

class MatchSummaryCard extends StatelessWidget {
  final String sportType;
  final String venueName;
  final DateTime? matchDate;
  final double totalPrice;
  final int currentPlayers;
  final int maximumPlayers;
  final String paymentMethod;

  const MatchSummaryCard({
    super.key,
    required this.sportType,
    required this.venueName,
    required this.matchDate,

    required this.totalPrice,
    required this.currentPlayers,

    required this.maximumPlayers,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Match Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const Divider(),

            _buildRow("Sport", sportType),

            _buildRow("Venue", venueName),

            _buildRow(
              "Date",
              matchDate == null
                  ? "-"
                  : "${matchDate!.day}/${matchDate!.month}/${matchDate!.year}",
            ),

            _buildRow("Total Price", "RM ${totalPrice.toStringAsFixed(2)}"),

            _buildRow(
              "Payment",
              paymentMethod == "equally" ? "Equally" : "Host Pays",
            ),

            _buildRow("Players", "$currentPlayers / $maximumPlayers"),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
