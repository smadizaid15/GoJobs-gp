import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/student_bottom_nav.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'Zaid Smadi.',
                              style: AppTextStyles.heading3.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.go('/student/settings'),
                              child: const Icon(
                                Icons.settings_outlined,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingS),
                            GestureDetector(
  onTap: () => context.push('/ai-chat'),
  child: Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: AppColors.primaryNavy,
      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
    ),
    child: const Icon(
      Icons.smart_toy_outlined,
      color: Colors.white,
      size: 18,
    ),
  ),
),
const SizedBox(width: AppDimensions.paddingS),
                            GestureDetector(
                              onTap: () => context.go('/student/profile'),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primaryNavy,
                                child: Text(
                                  'Z',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // 50% off banner
                    Container(
                      width: double.infinity,
                      height: 130,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusL),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                AppDimensions.paddingL,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '50% off',
                                    style: AppTextStyles.heading3.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'take any courses',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppDimensions.paddingS),
                                  GestureDetector(
                                    onTap: () =>
                                        context.go('/student/courses'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppDimensions.paddingM,
                                        vertical: AppDimensions.paddingXS,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryOrange,
                                        borderRadius: BorderRadius.circular(
                                          AppDimensions.radiusFull,
                                        ),
                                      ),
                                      child: Text(
                                        'Join Now',
                                        style:
                                            AppTextStyles.bodySmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight:
                                  Radius.circular(AppDimensions.radiusL),
                              bottomRight:
                                  Radius.circular(AppDimensions.radiusL),
                            ),
                            child: Image.asset(
                              'assets/images/woman_banner.png',
                              height: 130,
                              width: 110,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    Text(
                      'Find your Job/Course',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.go('/student/courses'),
                            child: Container(
                              padding: const EdgeInsets.all(
                                AppDimensions.paddingM,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusL,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.laptop_outlined,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                      height: AppDimensions.paddingS),
                                  Text(
                                    '4.5k',
                                    style: AppTextStyles.heading3.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'courses/workshops',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: AppDimensions.paddingM),

                        Expanded(
                          child: GestureDetector(
                            onTap: () => context
                                .go('/student/internship-categories'),
                            child: Container(
                              padding: const EdgeInsets.all(
                                AppDimensions.paddingM,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusL,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.work_outline,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                      height: AppDimensions.paddingS),
                                  Text(
                                    '3k+',
                                    style: AppTextStyles.heading3.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Internships',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    GestureDetector(
                      onTap: () =>
                          context.go('/student/service-providers'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusL),
                          border: Border.all(
                            color: AppColors.primaryOrange,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'In need of service providers ?',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingXS),
                            Text(
                              'Press here to uncover the word of freelancers and the variety of services they have to offer',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Internships',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context
                              .go('/student/internship-categories'),
                          child: Text(
                            'View all',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    _InternshipCard(
                      title: 'Data scientist',
                      company: 'Startup Company',
                      location: 'Amman, Jordan',
                      type: 'On site',
                      jobType: 'Full time',
                      onTap: () =>
                          context.push('/student/internship-list'),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    _InternshipCard(
                      title: 'Sunpaid',
                      company: 'Tech Corp',
                      location: 'Irbid, Jordan',
                      type: 'On site',
                      jobType: 'Full time',
                      onTap: () =>
                          context.push('/student/internship-list'),
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),
                  ],
                ),
              ),
            ),

            const StudentBottomNav(currentIndex: 0),
          ],
        ),
      ),
    );
  }
}

class _InternshipCard extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final String type;
  final String jobType;
  final VoidCallback onTap;

  const _InternshipCard({
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.jobType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
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
                  '$company • $location',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXS),
                Row(
                  children: [
                    _Tag(label: type),
                    const SizedBox(width: AppDimensions.paddingXS),
                    _Tag(label: jobType),
                  ],
                ),
              ],
            ),
            const Icon(
              Icons.bookmark_border,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      ),
    );
  }
}