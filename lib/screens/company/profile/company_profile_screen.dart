import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/company_bottom_nav.dart';

class CompanyProfileScreen extends StatelessWidget {
  const CompanyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryNavy, Color(0xFF1a1850)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft:
                              Radius.circular(AppDimensions.radiusXL),
                          bottomRight:
                              Radius.circular(AppDimensions.radiusXL),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Top icons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => context.go('/company/home'),
                                child: const Icon(
                                  Icons.share_outlined,
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    context.go('/company/settings'),
                                child: const Icon(
                                  Icons.settings_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          //  logo
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusL,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusL,
                              ),
                              child: Image.asset(
                                'assets/images/company_logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          Text(
                            'Calma Space',
                            style: AppTextStyles.heading3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            'Irbid, Jordan',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          // Edit profile 
                          GestureDetector(
                            onTap: () =>
                                context.go('/company/edit-profile'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingL,
                                vertical: AppDimensions.paddingXS,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull,
                                ),
                                border: Border.all(color: Colors.white54),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Edit profile',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                      width: AppDimensions.paddingXS),
                                  const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Profile tab
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      child: Column(
                        children: [
                          // Toggle buttons
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppDimensions.paddingS,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.companyGold,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusS,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Posted and active jobs',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingS),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      context.go('/company/applicants'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppDimensions.paddingS,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryNavy,
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusS,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Applicants',
                                        style:
                                            AppTextStyles.bodySmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          // Job listings
                          _JobItem(
                              title: 'Head manager', isChecked: false),
                          _JobItem(title: 'Barista', isChecked: false),
                          _JobItem(
                              title: 'Social media', isChecked: true),
                          _JobItem(
                              title: 'Cleaning staff', isChecked: true),
                          _JobItem(title: 'Cashier', isChecked: true),
                          _JobItem(title: 'Head bar', isChecked: false),
                          _JobItem(
                              title: 'Night shifts', isChecked: false),
                          _JobItem(
                              title: 'Branch manager', isChecked: true),

                          const SizedBox(height: AppDimensions.paddingL),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      context.go('/company/add-job'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: AppColors.companyGold),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppDimensions.radiusS),
                                    ),
                                  ),
                                  child: Text(
                                    'POST NEW JOB',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.companyGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingM),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      context.go('/company/jobs'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: AppColors.companyGold),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppDimensions.radiusS),
                                    ),
                                  ),
                                  child: Text(
                                    'MANAGE JOBS',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.companyGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.paddingXL),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const CompanyBottomNav(currentIndex: 1),
          ],
        ),
      ),
    );
  }
}

class _JobItem extends StatelessWidget {
  final String title;
  final bool isChecked;

  const _JobItem({required this.title, required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Checkbox(
            value: isChecked,
            activeColor: AppColors.companyGold,
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }
}