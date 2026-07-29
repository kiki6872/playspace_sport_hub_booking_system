import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:playspace_sport_hub_booking_system/src/core/constants/app_colors.dart';
import 'package:playspace_sport_hub_booking_system/src/core/theme/app_text_styles.dart';

import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/viewModels/register_viewmodel.dart';

import 'package:playspace_sport_hub_booking_system/src/widgets/custom_button.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/custom_textfield.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RegisterViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              Image.asset(
                'lib/assets/images/logo_playspace.jpeg',
                width: 100,
                height: 100,
              ),

              const SizedBox(height: 20),

              Text('Create Account', style: AppTextStyles.heading2),

              const SizedBox(height: 8),

              Text(
                'Create your PlaySpace account',
                style: AppTextStyles.bodyMedium,
              ),

              const SizedBox(height: 35),

              CustomTextField(
                controller: viewModel.fullNameController,
                hintText: 'Full Name',
                prefixIcon: Icons.person_outline,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: viewModel.emailController,
                hintText: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: viewModel.phoneController,
                hintText: 'Phone Number',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: viewModel.passwordController,
                hintText: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: viewModel.confirmPasswordController,
                hintText: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),

              const SizedBox(height: 30),

              CustomButton(
                text: 'CREATE ACCOUNT',
                isLoading: viewModel.isLoading,
                onPressed: () async {
                  final result = await viewModel.register();

                  if (!context.mounted) return;

                  if (result != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(result)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registration Successful')),
                    );

                    Navigator.pop(context);
                  }
                },
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: AppTextStyles.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Login'),
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
