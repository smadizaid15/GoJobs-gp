import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class JobseekerCheckEmailScreen extends StatefulWidget {
  const JobseekerCheckEmailScreen({super.key});

  @override
  State<JobseekerCheckEmailScreen> createState() =>
      _JobseekerCheckEmailScreenState();
}

class _JobseekerCheckEmailScreenState
    extends State<JobseekerCheckEmailScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Title
              Text(
                'Check Your Email',
                style: AppTextStyles.heading1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.paddingS),

              // Subtitle
              Text(
                'We have sent the reset password to the email address smadizaid@gmail.com',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Illustration
              Image.asset(
                'assets/images/Group67.png',
                height: 180,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Enter new password
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Enter new password', style: AppTextStyles.labelText),
              ),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  hintText: '••••••••••',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureNew = !_obscureNew;
                      });
                    },
                    child: Icon(
                      _obscureNew
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Confirm new password
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Confirm new password', style: AppTextStyles.labelText),
              ),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: '••••••••••',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                    child: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingS),

              // Resend link
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'You have not received the email? Resend',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Back to login button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: OutlinedButton(
                  onPressed: () => context.go('/jobseeker/login'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.secondaryPurple),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    backgroundColor:
                        AppColors.secondaryPurple.withValues(alpha: 0.3),
                  ),
                  child: Text(
                    'BACK TO LOGIN',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),
            ],
          ),
        ),
      ),
    );
  }
}