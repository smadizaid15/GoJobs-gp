import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class StudentApplicationSuccessScreen extends StatelessWidget {
  final Map<String, dynamic>? jobData;

  const StudentApplicationSuccessScreen({super.key, this.jobData});

  @override
  Widget build(BuildContext context) {
    final company = jobData?['companyName']?.toString() ?? 'Company';
    final title = jobData?['title']?.toString() ?? 'Position';
    final location = jobData?['location']?.toString() ?? 'Location';
    final logoUrl = jobData?['logoUrl']?.toString();

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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/student/home'),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Icon(Icons.more_vert, color: AppColors.textPrimary),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingL),

              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusL,
                        ),
                        image: logoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(logoUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: logoUrl == null
                          ? const Icon(
                              Icons.business,
                              color: AppColors.textSecondary,
                              size: 40,
                            )
                          : null,
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Text(
                      company,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              Center(
                child: Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXS),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      location,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Text(' • '),
                    Text(
                      company,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

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

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: OutlinedButton(
                  onPressed: () => context.go('/student/my-application'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.purpleButtonBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
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

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => context.go('/student/home'),
                  child: Text('BACK TO HOME', style: AppTextStyles.buttonText),
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
