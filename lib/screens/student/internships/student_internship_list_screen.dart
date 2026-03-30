import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class StudentInternshipListScreen extends StatelessWidget {
  const StudentInternshipListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.paddingL),

            // Back + Search
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        context.go('/student/internship-categories'),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppDimensions.paddingS),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search internships',
                                hintStyle: AppTextStyles.bodySmall,
                                border: InputBorder.none,
                                filled: false,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.tune,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'UI/UX Design Internships',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.paddingM),

            // Internship list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                children: [
                  _InternshipCard(
                    title: 'AI & Data Science Intern',
                    company: 'Calma Space',
                    location: 'Amman',
                    type: 'On site',
                    duration: '3 month internship',
                    onTap: () => context.push('/student/internship-detail')
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  _InternshipCard(
                    title: 'UI/UX Designer Intern',
                    company: 'Design Hub',
                    location: 'Irbid',
                    type: 'Hybrid',
                    duration: '6 month internship',
                    onTap: () => context.push('/student/internship-detail')
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  _InternshipCard(
                    title: 'Frontend Developer Intern',
                    company: 'Tech Corp',
                    location: 'Amman',
                    type: 'Remote',
                    duration: '3 month internship',
                    onTap: () => context.push('/student/internship-detail')
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  _InternshipCard(
                    title: 'Data Analyst Intern',
                    company: 'Analytics Co',
                    location: 'Amman',
                    type: 'On site',
                    duration: '4 month internship',
                    onTap: () => context.push('/student/internship-detail'),
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),
                ],
              ),
            ),
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
  final String duration;
  final VoidCallback onTap;

  const _InternshipCard({
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const Icon(
                  Icons.bookmark_border,
                  color: AppColors.textSecondary,
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.paddingS),

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

            const SizedBox(height: AppDimensions.paddingS),

            Row(
              children: [
                _Tag(label: type),
                const SizedBox(width: AppDimensions.paddingXS),
                _Tag(label: duration),
              ],
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