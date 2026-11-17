import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:playspace_sport_hub_booking_system/src/routes/app_routes.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/views/splash_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/views/login_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/views/register_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/views/forgot_password_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/viewModels/forgot_password_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/dashboard/views/booker_dashboard_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/dashboard/views/admin_dashboard_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/viewModels/login_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/viewModels/register_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/dashboard/views/vendor_dashboard_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/dashboard/viewModels/dashboard_viewmodel.dart'
    as booker;
import 'package:playspace_sport_hub_booking_system/src/modules/admin/dashboard/viewModels/dashboard_viewmodel.dart'
    as admin;
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/dashboard/viewModels/dashboard_viewmodel.dart'
    as vendor;

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          return ChangeNotifierProvider(
            create: (_) => LoginViewModel(),
            child: const LoginPage(),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) {
          return ChangeNotifierProvider(
            create: (_) => RegisterViewModel(),
            child: const RegisterPage(),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) {
          return ChangeNotifierProvider(
            create: (_) => ForgotPasswordViewModel(),
            child: const ForgotPasswordPage(),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.bookerDashboard,
        builder: (context, state) {
          return ChangeNotifierProvider(
            create: (_) => booker.DashboardViewModel(),
            child: const BookerDashboardPage(),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) {
          return ChangeNotifierProvider(
            create: (_) => admin.DashboardViewModel(),
            child: const AdminDashboardPage(),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.vendorDashboard,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => vendor.DashboardViewModel(),
          child: const VendorDashboardPage(),
        ),
      ),
    ],
  );
}
