import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/student_bottom_nav.dart';

class StudentInternshipCategoriesScreen extends StatelessWidget {
  const StudentInternshipCategoriesScreen({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {'title': 'UI/UX Design', 'jobs': '140 Jobs', 'icon': Icons.design_services_outlined},
    {'title': 'Finance', 'jobs': '250 Jobs', 'icon': Icons.attach_money_outlined},
    {'title': 'lab assistant', 'jobs': '120 Jobs', 'icon': Icons.science_outlined},
    {'title': 'Cyber security', 'jobs': '89 Jobs', 'icon': Icons.security_outlined},
    {'title': 'Artificial intelligence', 'jobs': '235 Jobs', 'icon': Icons.psychology_outlined},
    {'title': 'Programmer', 'jobs': '412 Jobs', 'icon': Icons.code_outlined},
  ];

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

                    // Back + Search row
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/student/home'),
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
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull,
                              ),
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
                                      hintText: 'Search',
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

                    const SizedBox(height: AppDimensions.paddingL),

                    Text(
                      'Categories',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    // Categories grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppDimensions.paddingM,
                        mainAxisSpacing: AppDimensions.paddingM,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isFirst = index == 0;
                        return GestureDetector(
                          onTap: () => context.push('/student/internship-list'),
                          child: Container(
                            padding: const EdgeInsets.all(
                              AppDimensions.paddingM,
                            ),
                            decoration: BoxDecoration(
                              color: isFirst
                                  ? AppColors.primaryNavy
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusL,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  cat['icon'] as IconData,
                                  color: isFirst
                                      ? Colors.white
                                      : AppColors.primaryOrange,
                                  size: 32,
                                ),
                                const SizedBox(height: AppDimensions.paddingS),
                                Text(
                                  cat['title'] as String,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isFirst
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  cat['jobs'] as String,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isFirst
                                        ? Colors.white70
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),
                  ],
                ),
              ),
            ),

            const StudentBottomNav(currentIndex: 2),
          ],
        ),
      ),
    );
  }
}