import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.paddingL),

              // GoJobs title centered
              Center(
                child: Text(
                  'GoJobs',
                  style: AppTextStyles.heading2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Illustration
              Center(
                child: Image.asset(
                  'assets/images/Group75.png',
                  height: size.height * 0.45,
                  fit: BoxFit.contain,
                ),
              ),

              const Spacer(),

              // Find Your — bold, no underline
DefaultTextStyle(
  style: const TextStyle(decoration: TextDecoration.none),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Find Your',
        style: AppTextStyles.heading1.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          decoration: TextDecoration.none,
          decorationThickness: 0,
        ),
      ),
      Text(
        'Ideal Job',
        style: AppTextStyles.heading1.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryOrange,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.primaryOrange,
        ),
      ),
      Text(
        'Here!',
        style: AppTextStyles.heading1.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          decoration: TextDecoration.none,
          decorationThickness: 0,
        ),
      ),
    ],
  ),
),

              const SizedBox(height: AppDimensions.paddingS),

              // Subtitle
              Text(
                'Explore all the most exciting job roles based on your interest and study major.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Arrow button bottom right
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => context.go('/welcome'),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryNavy,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: AppDimensions.iconM,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),
            ],
          ),
        ),
      ),
    );
  }
}