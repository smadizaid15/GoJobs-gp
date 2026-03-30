import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/jobseeker_bottom_nav.dart';

class JobseekerSavedScreen extends StatelessWidget {
  const JobseekerSavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Group75.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: AppDimensions.paddingXL),

                  Text(
                    'No Savings',
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingS),

                  Text(
                    "You don't have any jobs saved, please\nfind it in search to save jobs",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppDimensions.paddingXL),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingXL,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: () => context.go('/jobseeker/search'),
                        child: Text(
                          'FIND A JOB',
                          style: AppTextStyles.buttonText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const JobseekerBottomNav(currentIndex: 4),
          ],
        ),
      ),
    );
  }
}