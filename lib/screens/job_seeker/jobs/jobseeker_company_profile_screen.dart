import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class JobseekerCompanyProfileScreen extends StatelessWidget {
  const JobseekerCompanyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.paddingL),

              // Back + more
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
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
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Company logo + name
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

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          Text('Google',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary)),
                          const Text(' • '),
                          Text('Calma Space',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary)),
                          const Text(' • '),
                          Text('1 day ago',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // About company
                    Text(
                      'About Company',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    Text(
                      'Calma Space is a thriving coffee house with three branches, dedicated to creating a warm, welcoming environment for every guest.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    _CompanyInfoRow(
                        label: 'Facebook',
                        value: 'https://www.calmaspace.com',
                        isLink: true),
                    _CompanyInfoRow(
                        label: 'Industry', value: 'Coffee house'),
                    _CompanyInfoRow(
                        label: 'Employee size', value: '326 Employees'),
                    _CompanyInfoRow(
                        label: 'Head office',
                        value: 'thaqafa roundabout, Irbid, Jordan'),
                    _CompanyInfoRow(label: 'Type', value: 'Coffee house'),
                    _CompanyInfoRow(label: 'Since', value: '2022'),
                    _CompanyInfoRow(
                        label: 'Specialization',
                        value: 'Coffee house, people pleasing, etc'),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Company gallery
                    Text(
                      'Company Gallery',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.inputFill,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusM),
                            ),
                            child: const Icon(
                              Icons.image_outlined,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        Expanded(
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.inputFill,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusM),
                            ),
                            child: const Center(
                              child: Text(
                                '15 pictures',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Bookmark
                    Row(
                      children: [
                        const Icon(
                          Icons.bookmark_border,
                          color: AppColors.textSecondary,
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
    );
  }
}

class _CompanyInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLink;

  const _CompanyInfoRow({
    required this.label,
    required this.value,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: isLink
                  ? AppColors.primaryOrange
                  : AppColors.textSecondary,
              decoration:
                  isLink ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}