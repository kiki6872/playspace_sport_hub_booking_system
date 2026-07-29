import 'package:flutter/material.dart';
import 'package:playspace_sport_hub_booking_system/src/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/review/views/vendor_review_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/review/viewModels/review_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/services/auth_service.dart';
import 'package:playspace_sport_hub_booking_system/src/routes/app_routes.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/confirmation_dialog.dart';
import 'package:playspace_sport_hub_booking_system/src/core/utils/helper.dart';
import 'package:provider/provider.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/profile/viewModels/bank_account_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/profile/views/bank_account_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/viewModels/profile_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/views/profile_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/viewModels/change_password_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/views/change_password_page.dart';

class CustomDrawer extends StatelessWidget {
  final String role;

  CustomDrawer({super.key, required this.role});
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileViewModel>();
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1F2232)),
              accountName: Text(profile.fullName),

              accountEmail: Text(Helper.getRoleDescription(role)),
              currentAccountPicture: CircleAvatar(
                backgroundImage: profile.profileImage.isNotEmpty
                    ? NetworkImage(profile.profileImage)
                    : null,
                child: profile.profileImage.isEmpty
                    ? Text(
                        profile.fullName.isNotEmpty
                            ? profile.fullName[0].toUpperCase()
                            : "U",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    : null,
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Change Password"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => ChangePasswordViewModel(),
                      child: const ChangePasswordPage(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text("Bank Account"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => BankAccountViewModel(),
                      child: const BankAccountPage(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.reviews),
              title: const Text("Customer Reviews"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => ReviewViewModel(),
                      child: const VendorReviewPage(),
                    ),
                  ),
                );
              },
            ),

            const Spacer(),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (_) => ConfirmationDialog(
                    title: "Logout",
                    message: "Are you sure you want to logout?",
                    confirmButtonText: "Logout",
                    onConfirm: () async {
                      Navigator.pop(context);
                      Navigator.pop(context);

                      await _authService.logout();

                      if (!context.mounted) return;

                      context.read<ProfileViewModel>().clear();

                      context.go(AppRoutes.login);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
