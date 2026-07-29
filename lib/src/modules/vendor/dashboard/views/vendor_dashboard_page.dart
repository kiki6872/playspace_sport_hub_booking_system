import 'package:flutter/material.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/custom_drawer.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/custom_bottom_navbar.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/summary_widget.dart';
import 'package:playspace_sport_hub_booking_system/src/core/constants/app_icons.dart';
import 'package:provider/provider.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/viewModels/profile_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/venue/viewModels/venue_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/revenue/viewModels/revenue_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/dashboard/viewModels/dashboard_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/venue/views/vendor_venue_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/schedule/views/schedule_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/revenue/views/revenue_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/promotion/viewModels/promotion_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/promotion/views/promotion_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/schedule/viewModels/booking_schedule_viewmodel.dart';

class VendorDashboardPage extends StatefulWidget {
  const VendorDashboardPage({super.key});

  @override
  State<VendorDashboardPage> createState() => _VendorDashboardPageState();
}

class _VendorDashboardPageState extends State<VendorDashboardPage> {
  int currentIndex = 0;

  void onTabSelected(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel = context.read<DashboardViewModel>();

      viewModel.loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    final profile = context.watch<ProfileViewModel>();
    return Scaffold(
      drawer: CustomDrawer(role: "vendor"),

      body: [
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Builder(
                      builder: (context) {
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.menu, size: 28),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        );
                      },
                    ),

                    const SizedBox(width: 16),

                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFC8F528),
                      backgroundImage: profile.profileImage.isNotEmpty
                          ? NetworkImage(profile.profileImage)
                          : null,
                      child: profile.profileImage.isEmpty
                          ? Text(
                              profile.fullName.isNotEmpty
                                  ? profile.fullName[0].toUpperCase()
                                  : "V",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, ${profile.fullName}!",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Image.asset(
                        "lib/assets/images/vendor_back.jpg",
                        width: double.infinity,
                        height: 170,
                        fit: BoxFit.cover,
                      ),

                      Container(
                        width: double.infinity,
                        height: 170,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.75),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      const Positioned(
                        left: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Vendor Dashboard",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              "Manage venues and bookings efficiently",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                const Text(
                  "Overview",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 150,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      SizedBox(
                        width: 170,
                        child: SummaryWidget(
                          title: "My Venues",
                          value: viewModel.totalVenues.toString(),
                          icon: Icons.store,
                        ),
                      ),

                      const SizedBox(width: 16),

                      SizedBox(
                        width: 170,
                        child: SummaryWidget(
                          title: "Bookings",
                          value: viewModel.todayBookings.toString(),
                          icon: Icons.calendar_month,
                        ),
                      ),

                      const SizedBox(width: 16),

                      SizedBox(
                        width: 170,
                        child: SummaryWidget(
                          title: "Revenue",
                          value: "RM${viewModel.revenue.toStringAsFixed(2)}",
                          icon: Icons.attach_money,
                        ),
                      ),

                      const SizedBox(width: 16),

                      SizedBox(
                        width: 170,
                        child: SummaryWidget(
                          title: "Pending",
                          value: viewModel.pendingVenues.toString(),
                          icon: Icons.pending_actions,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                const Text(
                  "Recent Activities",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                viewModel.recentActivities.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2232),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.store, color: Colors.orange),
                          title: Text(
                            "No recent activities",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "Your venue activities will appear here.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: viewModel.recentActivities.length,
                        itemBuilder: (_, index) {
                          final activity = viewModel.recentActivities[index];

                          return Card(
                            color: const Color(0xFF1F2232),
                            child: ListTile(
                              leading: const Icon(
                                Icons.event,
                                color: Colors.orange,
                              ),
                              title: Text(
                                activity["venueName"],
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "${activity["bookerName"]} • ${activity["status"]}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => VenueViewModel(),
          child: const VendorVenuePage(),
        ),

        ChangeNotifierProvider(
          create: (_) => BookingScheduleViewModel(),
          child: const VendorSchedulePage(),
        ),

        ChangeNotifierProvider(
          create: (_) => RevenueViewModel(),
          child: const EarningsPage(),
        ),

        ChangeNotifierProvider(
          create: (_) => PromotionViewModel(),
          child: const PromotionPage(),
        ),
      ][currentIndex],

      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: currentIndex,
        onTap: onTabSelected,
        items: [
          NavItem(
            label: "Home",
            activeIcon: AppIcons.homeActive,
            inactiveIcon: AppIcons.homeInactive,
          ),

          NavItem(
            label: "Listing",
            activeIcon: AppIcons.listActive,
            inactiveIcon: AppIcons.listInactive,
          ),

          NavItem(
            label: "Schedule",
            activeIcon: AppIcons.bookActive,
            inactiveIcon: AppIcons.bookInactive,
          ),

          NavItem(
            label: "Earnings",
            activeIcon: AppIcons.earningActive,
            inactiveIcon: AppIcons.earningInactive,
          ),

          NavItem(
            label: "Promotion",
            activeIcon: AppIcons.rewardActive,
            inactiveIcon: AppIcons.rewardInactive,
          ),
        ],
      ),
    );
  }
}
