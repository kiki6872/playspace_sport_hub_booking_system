import 'package:flutter/material.dart';

class BookingSummaryDialog extends StatelessWidget {
  final String venueName;
  final String date;
  final String time;
  final double price;
  final double discount;
  final double total;
  final String? voucher;
  final String? promotion;
  final VoidCallback onConfirm;

  const BookingSummaryDialog({
    super.key,
    required this.venueName,
    required this.date,
    required this.time,
    required this.price,
    required this.discount,
    required this.total,
    this.voucher,
    this.promotion,
    required this.onConfirm,
  });

  Widget buildRow(
    String title,
    String value, {
    Color? color,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 18 : 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xff1d1b35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Booking Summary",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 25),

            buildRow("Venue", venueName),

            buildRow("Date", date),

            buildRow("Time", time),

            const Divider(height: 30),

            buildRow("Price", "RM ${price.toStringAsFixed(2)}"),

            if (promotion != null)
              buildRow("Promotion", promotion!, color: Colors.green),

            if (voucher != null)
              buildRow("Voucher", voucher!, color: Colors.orange),

            if (discount > 0)
              buildRow(
                "Discount",
                "-RM ${discount.toStringAsFixed(2)}",
                color: Colors.redAccent,
              ),

            const Divider(height: 30),

            buildRow(
              "Total",
              "RM ${total.toStringAsFixed(2)}",
              bold: true,
              color: const Color(0xffb6ff00),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffb6ff00),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onConfirm,
                      child: const Text(
                        "Confirm",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
