import 'package:flutter/material.dart';

import 'package:playspace_sport_hub_booking_system/src/core/constants/app_colors.dart';
import 'package:playspace_sport_hub_booking_system/src/core/theme/app_text_styles.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final String profileImage;

  const DashboardHeader({
    super.key,
    required this.userName,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu, color: Colors.white),
          ),
        ),

        const SizedBox(width: 8),

        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary,
          backgroundImage: profileImage.isNotEmpty
              ? NetworkImage(profileImage)
              : null,
          child: profileImage.isEmpty
              ? Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )
              : null,
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hi', style: AppTextStyles.bodyMedium),

              const SizedBox(height: 4),

              Text("$userName!", style: AppTextStyles.heading2),

              const SizedBox(height: 4),

              Text(
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
