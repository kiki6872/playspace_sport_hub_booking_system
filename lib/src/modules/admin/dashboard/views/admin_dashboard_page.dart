import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:playspace_sport_hub_booking_system/src/core/constants/app_colors.dart';
import 'package:playspace_sport_hub_booking_system/src/core/constants/app_icons.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/custom_bottom_navbar.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/custom_drawer.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/summary_widget.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/viewModels/profile_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/dashboard/viewModels/dashboard_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/users/views/users_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/users/viewModels/users_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/venues/views/venues_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/venues/viewModels/admin_venue_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/promotions/views/promotion_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/promotions/viewModels/promotion_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/reports/views/reports_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboardData();
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardViewModel>();
    final profile = context.watch<ProfileViewModel>();

    return Scaffold(
      body: [
        DashboardHome(
          userName: profile.profile["fullName"] ?? "",
          profileImage: profile.profile["profileImage"] ?? "",
          totalUsers: dashboard.totalUsers,
          totalVendors: dashboard.totalVendors,
          totalVenues: dashboard.totalVenues,
          pendingVenues: dashboard.pendingVenues,
          pendingPromotions: dashboard.pendingPromotions,
        ),
        ChangeNotifierProvider(
          create: (_) => UsersViewModel(),
          child: const UsersPage(),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminVenueViewModel(),
          child: const VenuesPage(),
        ),
        ChangeNotifierProvider(
          create: (_) => PromotionViewModel(),
          child: const PromotionPage(),
        ),
        const ReportsPage(),
      ][currentIndex],

      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          if (index == 0) {
            dashboard.loadDashboardData();
            profile.loadProfile();
          }
        },
        items: [
          NavItem(
            label: "Home",
            activeIcon: AppIcons.homeActive,
            inactiveIcon: AppIcons.homeInactive,
          ),
          NavItem(
            label: "Users",
            activeIcon: AppIcons.usersActive,
            inactiveIcon: AppIcons.usersInactive,
          ),
          NavItem(
            label: "Venues",
            activeIcon: AppIcons.venuesActive,
            inactiveIcon: AppIcons.venuesInactive,
          ),
          NavItem(
            label: "Promotions",
            activeIcon: AppIcons.rewardActive,
            inactiveIcon: AppIcons.rewardInactive,
          ),
          NavItem(
            label: "Reports",
            activeIcon: AppIcons.reportsActive,
            inactiveIcon: AppIcons.reportsInactive,
          ),
        ],
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  final String userName;
  final String profileImage;
  final int totalUsers;
  final int totalVendors;
  final int totalVenues;
  final int pendingVenues;
  final int pendingPromotions;

  const DashboardHome({
    super.key,
    required this.userName,
    required this.profileImage,
    required this.totalUsers,
    required this.totalVendors,
    required this.totalVenues,
    required this.pendingVenues,
    required this.pendingPromotions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(role: "admin"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              /// Header
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
                    backgroundImage: profileImage.isNotEmpty
                        ? NetworkImage(profileImage)
                        : null,
                    child: profileImage.isEmpty
                        ? Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : "A",
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
                          "Hi, $userName!",
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

              const SizedBox(height: 35),
              const SizedBox(height: 35),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),

                child: Stack(
                  children: [
                    Image.asset(
                      "lib/assets/images/dash_back.jpg",
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
                            "PlaySpace Admin",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            "Manage your sports hub efficiently",
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
                        title: "Users",
                        value: totalUsers.toString(),
                        icon: Icons.people,
                      ),
                    ),

                    const SizedBox(width: 16),

                    SizedBox(
                      width: 170,
                      child: SummaryWidget(
                        title: "Vendors",
                        value: totalVendors.toString(),
                        icon: Icons.store,
                      ),
                    ),

                    const SizedBox(width: 16),

                    SizedBox(
                      width: 170,
                      child: SummaryWidget(
                        title: "Venues",
                        value: totalVenues.toString(),
                        icon: Icons.sports_soccer,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 35),
              const Text(
                "Pending Actions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          "Pending Actions",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        const Icon(Icons.sports_soccer, size: 18),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            "$pendingVenues venue(s) waiting approval",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(Icons.local_offer, size: 18),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            "$pendingPromotions promotion(s) waiting approval",
                          ),
                        ),
                      ],
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

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2232),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.store, color: Colors.white, size: 18),
                      ),
                      title: Text(
                        "New venue submitted",
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "Waiting for admin approval",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                    Divider(color: Colors.white12),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        "New vendor registered",
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "Vendor account created",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                    Divider(color: Colors.white12),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.local_offer,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        "Promotion approved",
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "Latest approved promotion",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
