import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/company_bottom_nav.dart';

class CompanyJobsScreen extends StatelessWidget {
  const CompanyJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimensions.paddingL),

                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/company/home'),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Jobs',
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/company/add-job'),
                          child: const Icon(
                            Icons.add,
                            color: AppColors.companyGold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Job cards
                    _JobCard(
                      title: 'Head Manager',
                      applicants: '12 applicants',
                      status: 'Active',
                      onTap: () => context.push('/company/applicants'),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    _JobCard(
                      title: 'Barista',
                      applicants: '8 applicants',
                      status: 'Active',
                      onTap: () => context.push('/company/applicants'),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    _JobCard(
                      title: 'Social Media Manager',
                      applicants: '5 applicants',
                      status: 'Active',
                      onTap: () => context.push('/company/applicants'),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    _JobCard(
                      title: 'Cleaning Staff',
                      applicants: '3 applicants',
                      status: 'Closed',
                      onTap: () => context.push('/company/applicants'),
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),
                  ],
                ),
              ),
            ),

            const CompanyBottomNav(currentIndex: -1),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String applicants;
  final String status;
  final VoidCallback onTap;

  const _JobCard({
    required this.title,
    required this.applicants,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'Active';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  applicants,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingXS,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.companyGold.withValues(alpha: 0.15)
                    : AppColors.inputFill,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                status,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isActive
                      ? AppColors.companyGold
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}