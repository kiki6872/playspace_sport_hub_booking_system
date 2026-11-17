import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playspace_sport_hub_booking_system/src/routes/app_routes.dart';
import 'package:playspace_sport_hub_booking_system/src/core/constants/app_colors.dart';
import 'package:playspace_sport_hub_booking_system/src/core/theme/app_text_styles.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/custom_button.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/viewModels/login_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/viewModels/profile_viewmodel.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Logo
              Center(
                child: Image.asset(
                  'lib/assets/images/logo_playspace.jpeg',
                  width: 120,
                  height: 120,
                ),
              ),

              const SizedBox(height: 24),

              Text('Welcome Back', style: AppTextStyles.heading2),

              const SizedBox(height: 8),

              Text('Sign in to your account', style: AppTextStyles.bodyMedium),

              const SizedBox(height: 40),

              CustomTextField(
                controller: viewModel.emailController,
                hintText: 'Email Address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: viewModel.passwordController,
                hintText: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.push(AppRoutes.forgotPassword);
                  },
                  child: Text(
                    'Forgot Password?',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: 'LOGIN',
                isLoading: viewModel.isLoading,
                onPressed: () async {
                  final result = await viewModel.login();

                  if (!context.mounted) return;

                  if (result == 'booker' ||
                      result == 'vendor' ||
                      result == 'admin') {
                    await context.read<ProfileViewModel>().loadProfile();
                  }

                  if (!context.mounted) return;

                  if (result == 'booker') {
                    context.go(AppRoutes.bookerDashboard);
                  } else if (result == 'vendor') {
                    context.go(AppRoutes.vendorDashboard);
                  } else if (result == 'admin') {
                    context.go(AppRoutes.adminDashboard);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result ?? 'Login failed')),
                    );
                  }
                },
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: AppTextStyles.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      context.push(AppRoutes.register);
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
