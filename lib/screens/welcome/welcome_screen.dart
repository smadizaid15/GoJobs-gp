import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
          ),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Illustration
              Center(
                child: Image.asset(
                  'assets/images/Group75.png',
                  height: size.height * 0.28,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Company card
              _RoleCard(
                title: 'Company',
                description: 'Post job openings and hire the right talent for your business.',
                onSignUp: () => context.go('/company/signup'),
                onLogin: () => context.go('/company/login'),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Job Seeker card
              _RoleCard(
                title: 'Job Seeker',
                description: 'Find jobs, build your profile, and apply instantly, in addition to providing your skills for people to hire you.',
                onSignUp: () => context.go('/jobseeker/signup'),
                onLogin: () => context.go('/jobseeker/login'),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Student card
              _RoleCard(
                title: 'Student',
                description: 'Dive right in to the world of courses, trainings, workshops, and many more!',
                onSignUp: () => context.go('/student/signup'),
                onLogin: () => context.go('/student/login'),
              ),

              const SizedBox(height: AppDimensions.paddingXL),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onSignUp;
  final VoidCallback onLogin;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.onSignUp,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title banner only
        GestureDetector(
          onTap: onSignUp,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.paddingM,
              horizontal: AppDimensions.paddingL,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.paddingS),

        // Description outside banner
        Text(
          description,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: AppDimensions.paddingS),

        // Buttons centered
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: onSignUp,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                    vertical: AppDimensions.paddingS,
                  ),
                ),
                child: Text(
                  'Sign up',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingS),
              OutlinedButton(
                onPressed: onLogin,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                    vertical: AppDimensions.paddingS,
                  ),
                ),
                child: Text(
                  'Log in',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}