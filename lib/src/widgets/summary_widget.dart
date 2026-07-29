import 'package:flutter/material.dart';

import 'package:playspace_sport_hub_booking_system/src/core/constants/app_colors.dart';

class SummaryWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const SummaryWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 30),

          const SizedBox(height: 20),

          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 15)),
        ],
      ),
    );
  }
}
