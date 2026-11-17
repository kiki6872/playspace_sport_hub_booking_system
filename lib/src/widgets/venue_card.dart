import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/favourite/viewModels/fav_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/core/constants/app_colors.dart';
import 'package:playspace_sport_hub_booking_system/src/core/theme/app_text_styles.dart';

class VenueCard extends StatelessWidget {
  final String venueId;
  final String name;
  final String address;
  final String sportType;
  final double rating;
  final double pricePerHour;
  final String imageUrl;
  final VoidCallback? onTap;

  const VenueCard({
    super.key,
    required this.venueId,
    required this.name,
    required this.address,
    required this.sportType,
    required this.rating,
    required this.pricePerHour,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Venue Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: imageUrl.isEmpty
                      ? Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey.shade800,
                          child: const Icon(
                            Icons.image,
                            color: Colors.white54,
                            size: 45,
                          ),
                        )
                      : Image.network(
                          imageUrl,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),

                Positioned(
                  top: 10,
                  right: 10,
                  child: Consumer<FavouriteViewModel>(
                    builder: (context, favVM, child) {
                      final isFav = favVM.isFavourite(venueId);

                      return GestureDetector(
                        onTap: () async {
                          await favVM.toggleFavourite(venueId);
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.heading3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          style: AppTextStyles.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          sportType,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const Spacer(),

                      const Icon(Icons.star, color: Colors.amber, size: 18),

                      const SizedBox(width: 4),

                      Text(
                        rating.toStringAsFixed(1),
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'RM ${pricePerHour.toStringAsFixed(0)} / hour',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
