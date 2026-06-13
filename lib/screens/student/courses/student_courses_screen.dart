import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String _searchQuery = '';
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
            // Header & Search Box
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
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textSecondary),
                        const SizedBox(width: AppDimensions.paddingS),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                            decoration: InputDecoration(
                              hintText: 'Search for Python, UI/UX...',
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

            // Live Course List from Firebase
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('courses').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading courses.'));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No courses available right now.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  // Apply search and filter logic
                  final filteredCourses = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title']?.toString().toLowerCase() ?? '';
                    final isFree = data['isFree'] as bool? ?? false;
                    final isOnline = data['isOnline'] as bool? ?? false;

                    // Search query match
                    bool matchesSearch = title.contains(_searchQuery);

                    // Filter match
                    bool matchesFilter = true;
                    if (_filters[_selectedFilter] == 'Free') matchesFilter = isFree;
                    if (_filters[_selectedFilter] == 'Online') matchesFilter = isOnline;
                    if (_filters[_selectedFilter] == 'On-Site') matchesFilter = !isOnline;

                    return matchesSearch && matchesFilter;
                  }).toList();

                  if (filteredCourses.isEmpty) {
                    return Center(
                      child: Text(
                        'No courses match your filter.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      final doc = filteredCourses[index];
                      final data = doc.data() as Map<String, dynamic>;
                      
                      final courseDataForDetail = {
                        'id': doc.id,
                        ...data,
                      };

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                        child: _CourseCard(
                          title: data['title'] ?? 'Unknown Course',
                          company: data['companyName'] ?? 'Unknown Institution',
                          location: (data['isOnline'] as bool? ?? false) ? 'Online' : (data['location'] ?? 'On-site'),
                          tags: List<String>.from(data['tags'] ?? []),
                          price: (data['isFree'] as bool? ?? false) ? 'Free' : (data['price'] ?? 'Paid'),
                          isPaid: !(data['isFree'] as bool? ?? false),
                          logoUrl: data['logoUrl'],
                          onTap: () => context.push('/student/course-detail', extra: courseDataForDetail),
                        ),
                      );
                    },
                  );
                },
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
  final String? logoUrl;
  final VoidCallback onTap;

  const _CourseCard({
    required this.title,
    required this.company,
    required this.location,
    required this.tags,
    required this.price,
    required this.isPaid,
    this.logoUrl,
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
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    image: logoUrl != null 
                        ? DecorationImage(image: NetworkImage(logoUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: logoUrl == null 
                      ? const Icon(Icons.business, color: AppColors.textSecondary, size: 20)
                      : null,
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
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
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

            Text(
              price,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isPaid ? AppColors.textPrimary : AppColors.primaryOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}