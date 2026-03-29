import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/student_bottom_nav.dart';

class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
  final _searchController = TextEditingController();
  final _locationController = TextEditingController();
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Online', 'On-Site', 'Free'];

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          children: [
            // Search header
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: const BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppDimensions.radiusXL),
                  bottomRight: Radius.circular(AppDimensions.radiusXL),
                ),
              ),
              child: Column(
                children: [
                  // Back + title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/student/home'),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Text(
                        'Courses & Workshops',
                        style: AppTextStyles.heading3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // Search bar
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textSecondary),
                        const SizedBox(width: AppDimensions.paddingS),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Python course',
                              hintStyle: AppTextStyles.bodySmall,
                              border: InputBorder.none,
                              filled: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingS),

                  // Location bar
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primaryOrange,
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        Expanded(
                          child: TextField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              hintText: 'Irbid',
                              hintStyle: AppTextStyles.bodySmall,
                              border: InputBorder.none,
                              filled: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingM),

            // Filter chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: AppDimensions.paddingS),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedFilter == index
                            ? AppColors.primaryNavy
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Text(
                        _filters[index],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _selectedFilter == index
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: _selectedFilter == index
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppDimensions.paddingM),

            // Course list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                children: [
                  _CourseCard(
                    title: 'Data science with python',
                    company: 'wowie inc',
                    location: 'Online',
                    tags: ['Python', 'On-site', 'Sci-kit/pandas'],
                    price: 'JOD 250/course',
                    isPaid: true,
                    onTap: () => context.go('/student/course-detail'),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  _CourseCard(
                    title: 'Ai using python',
                    company: 'Dribble inc',
                    location: 'Amman, Jordan',
                    tags: ['Python', 'On-site', 'ML/DL'],
                    price: 'Free',
                    isPaid: false,
                    onTap: () => context.go('/student/course-detail'),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  _CourseCard(
                    title: 'UI/UX Design Fundamentals',
                    company: 'Design Hub',
                    location: 'Online',
                    tags: ['Figma', 'Online', 'Design'],
                    price: 'JOD 150/course',
                    isPaid: true,
                    onTap: () => context.go('/student/course-detail'),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  _CourseCard(
                    title: 'Web Development Bootcamp',
                    company: 'Tech Academy',
                    location: 'Irbid, Jordan',
                    tags: ['HTML', 'CSS', 'JavaScript'],
                    price: 'Free',
                    isPaid: false,
                    onTap: () => context.go('/student/course-detail'),
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),
                ],
              ),
            ),

            const StudentBottomNav(currentIndex: 2),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final List<String> tags;
  final String price;
  final bool isPaid;
  final VoidCallback onTap;

  const _CourseCard({
    required this.title,
    required this.company,
    required this.location,
    required this.tags,
    required this.price,
    required this.isPaid,
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
                // Company logo placeholder
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

            // Tags
            Wrap(
              spacing: AppDimensions.paddingXS,
              children: tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    tag,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppDimensions.paddingS),

            // Price
            Text(
              price,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isPaid
                    ? AppColors.textPrimary
                    : AppColors.primaryOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
