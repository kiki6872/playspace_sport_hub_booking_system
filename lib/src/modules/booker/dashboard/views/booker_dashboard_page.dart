import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:playspace_sport_hub_booking_system/src/core/constants/app_colors.dart';
import 'package:playspace_sport_hub_booking_system/src/core/constants/app_icons.dart';
import 'package:playspace_sport_hub_booking_system/src/core/theme/app_text_styles.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/favourite/viewModels/fav_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/dashboard/viewModels/dashboard_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/venue/views/venue_details_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/booking/views/booking_setup_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/search/views/search_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/match/views/match_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/reward/views/reward_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/favourite/views/fav_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/booking/views/my_booking_page.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/category_chip.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/custom_bottom_navbar.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/custom_drawer.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/dashboard_header.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/venue_card.dart';

class BookerDashboardPage extends StatefulWidget {
  const BookerDashboardPage({super.key});

  @override
  State<BookerDashboardPage> createState() => _BookerDashboardPageState();
}

class _BookerDashboardPageState extends State<BookerDashboardPage> {
  int currentIndex = 0;
  int _selectedCategory = 0;

  final List<String> _categories = [
    'All',
    'Badminton',
    'Football',
    'Futsal',
    'Basketball',
    'Tennis',
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final vm = context.read<DashboardViewModel>();

      await vm.loadCurrentUser();
      await vm.loadVenues();
      await vm.loadLatestBookings();
      await context.read<FavouriteViewModel>().loadFavourites();
    });
    ;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    return Scaffold(
      drawer: CustomDrawer(role: "booker"),
      backgroundColor: AppColors.background,

      body: [
        /// ================= HOME =================
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardHeader(
                  userName: viewModel.userName,
                  profileImage: viewModel.profileImage,
                ),

                const SizedBox(height: 30),

                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: context.read<DashboardViewModel>(),
                          child: const SearchPage(),
                        ),
                      ),
                    );
                  },
                  child: IgnorePointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search venue...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return CategoryChip(
                        title: _categories[index],
                        isSelected: _selectedCategory == index,
                        onTap: () {
                          setState(() {
                            _selectedCategory = index;
                          });

                          context.read<DashboardViewModel>().filterSport(
                            _categories[index],
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                Text('Nearby Venues', style: AppTextStyles.heading3),

                const SizedBox(height: 16),

                SizedBox(
                  height: 320,
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: viewModel.filteredVenues.length,
                          itemBuilder: (context, index) {
                            final venue = viewModel.filteredVenues[index];

                            return VenueCard(
                              venueId: venue.id,
                              name: venue.name,
                              address: venue.address,
                              sportType: venue.sportType,
                              rating: venue.rating,
                              pricePerHour: venue.pricePerHour,
                              imageUrl: venue.imageUrl,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        VenueDetailsPage(venue: venue),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Bookings', style: AppTextStyles.heading3),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyBookingsPage(),
                          ),
                        );
                      },
                      child: const Text("See All"),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 175,
                  child: viewModel.latestBookings.isEmpty
                      ? const Center(child: Text("No bookings yet"))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: viewModel.latestBookings.length,
                          itemBuilder: (context, index) {
                            final booking = viewModel.latestBookings[index];

                            return Container(
                              width: 190,

                              margin: const EdgeInsets.only(right: 15),

                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),

                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.sports_soccer,
                                      color: Colors.green,
                                      size: 28,
                                    ),

                                    const SizedBox(height: 12),

                                    Text(
                                      booking.venueName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      DateFormat(
                                        "dd MMM yyyy",
                                      ).format(booking.bookingDate),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      "${booking.startTime} - ${booking.endTime}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),

                                    Builder(
                                      builder: (_) {
                                        final now = DateTime.now();

                                        final today = DateTime(
                                          now.year,
                                          now.month,
                                          now.day,
                                        );

                                        final bookingDay = DateTime(
                                          booking.bookingDate.year,
                                          booking.bookingDate.month,
                                          booking.bookingDate.day,
                                        );

                                        final difference = bookingDay
                                            .difference(today)
                                            .inDays;

                                        String label;

                                        if (booking.status == "cancelled") {
                                          label = "Cancelled";
                                        } else if (difference == 0) {
                                          label = "Today";
                                        } else if (difference == 1) {
                                          label = "Tomorrow";
                                        } else if (difference > 1) {
                                          label = "In $difference days";
                                        } else {
                                          label = "Completed";
                                        }

                                        return Text(
                                          label,
                                          style: TextStyle(
                                            color: difference <= 1
                                                ? Colors.green
                                                : Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),

        /// ================= BOOK =================
        const BookingSetupPage(),

        /// ================= MATCH =================
        const MatchPage(),

        /// ================= REWARD =================
        const RewardPage(),

        /// ================= CHAT =================
        const FavouritePage(),
      ][currentIndex],

      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          NavItem(
            label: 'Home',
            activeIcon: AppIcons.homeActive,
            inactiveIcon: AppIcons.homeInactive,
          ),
          NavItem(
            label: 'Book',
            activeIcon: AppIcons.bookActive,
            inactiveIcon: AppIcons.bookInactive,
          ),
          NavItem(
            label: 'Match',
            activeIcon: AppIcons.matchActive,
            inactiveIcon: AppIcons.matchInactive,
          ),
          NavItem(
            label: 'Reward',
            activeIcon: AppIcons.rewardActive,
            inactiveIcon: AppIcons.rewardInactive,
          ),
          NavItem(
            label: 'Favourite',
            activeIcon: AppIcons.favActive,
            inactiveIcon: AppIcons.favInactive,
          ),
        ],
      ),
    );
  }
}
