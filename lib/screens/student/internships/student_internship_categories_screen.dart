import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/student_bottom_nav.dart';

class StudentInternshipCategoriesScreen extends StatelessWidget {
  const StudentInternshipCategoriesScreen({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {'title': 'UI/UX Design', 'icon': Icons.design_services_outlined},
    {'title': 'Finance', 'icon': Icons.attach_money_outlined},
    {'title': 'Lab assistant', 'icon': Icons.science_outlined},
    {'title': 'Cyber security', 'icon': Icons.security_outlined},
    {'title': 'Artificial intelligence', 'icon': Icons.psychology_outlined},
    {'title': 'Programmer', 'icon': Icons.code_outlined},
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

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('jobs')
                          .where('jobType', isEqualTo: 'Internship')
                          .where('isActive', isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        Map<String, int> categoryCounts = {};
                        for (var cat in _categories) {
                          categoryCounts[cat['title']] = 0;
                        }

                        if (snapshot.hasData) {
                          for (var doc in snapshot.data!.docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            final category = data['category']?.toString() ?? '';

                            for (var cat in _categories) {
                              if (cat['title'].toString().toLowerCase() ==
                                  category.toLowerCase()) {
                                categoryCounts[cat['title']] =
                                    (categoryCounts[cat['title']] ?? 0) + 1;
                                break;
                              }
                            }
                          }
                        }

                        return GridView.builder(
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
                            final title = cat['title'] as String;
                            final isFirst = index == 0;

                            final jobCount = categoryCounts[title] ?? 0;

                            return GestureDetector(
                              onTap: () => context.push(
                                '/student/internship-list',
                                extra: title,
                              ),
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
                                    const SizedBox(
                                      height: AppDimensions.paddingS,
                                    ),
                                    Text(
                                      title,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isFirst
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '$jobCount Jobs',
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
