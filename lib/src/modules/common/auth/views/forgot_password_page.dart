import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:playspace_sport_hub_booking_system/src/core/constants/app_colors.dart';
import 'package:playspace_sport_hub_booking_system/src/core/theme/app_text_styles.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/viewModels/forgot_password_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/custom_button.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/custom_textfield.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ForgotPasswordViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Forgot Password', style: AppTextStyles.heading2),

              const SizedBox(height: 8),

              Text(
                'Enter your email to receive a password reset link.',
                style: AppTextStyles.bodyMedium,
              ),

              const SizedBox(height: 30),

              CustomTextField(
                controller: viewModel.emailController,
                hintText: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),

              const SizedBox(height: 30),

              CustomButton(
                text: 'SEND RESET LINK',
                isLoading: viewModel.isLoading,
                onPressed: () async {
                  final result = await viewModel.resetPassword();

                  if (!context.mounted) return;

                  if (result != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(result)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset email sent.'),
                      ),
                    );

                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
