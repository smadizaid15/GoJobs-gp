import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class StudentApplicationSuccessScreen extends StatelessWidget {
  const StudentApplicationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.paddingL),

              // Back + more options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/student/internship-detail'),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Icon(
                    Icons.more_vert,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Company logo
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusL),
                      ),
                      child: const Icon(
                        Icons.business,
                        color: AppColors.textSecondary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Text(
                      'Calma Space',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Job title
              Center(
                child: Text(
                  'Head Manager',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXS),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Irbid',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Text(' • '),
                    Text(
                      'Calma Space',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Text(' • '),
                    Text(
                      '1 day ago',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // CV 
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.purpleButton,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.purpleButtonBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Zaid Kilany - CV - Head barista',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '867 Kb • 14 Feb 2022 at 11:30 am',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Success 
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.primaryOrange,
                size: 80,
              ),

              const SizedBox(height: AppDimensions.paddingM),

              Text(
                'Successful',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXS),

              Text(
                'Congratulations, your application has been sent',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // View application 
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: OutlinedButton(
                  onPressed: () => context.go('/student/my-application'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.purpleButtonBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    backgroundColor: AppColors.purpleButton,
                  ),
                  child: Text(
                    'VIEW APPLICATION',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Back to home 
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => context.go('/student/home'),
                  child: Text(
                    'BACK TO HOME',
                    style: AppTextStyles.buttonText,
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