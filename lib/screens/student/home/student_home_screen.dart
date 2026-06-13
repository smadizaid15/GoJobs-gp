import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/student_bottom_nav.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _studentName = 'Student';
  String? _profileImageUrl;
  int _internshipCount = 0;
  int _courseCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
    _countInternships();
    _countCourses();
  }

  Future<void> _loadStudentProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          setState(() {
            _studentName = data['fullName'] ?? data['displayName'] ?? 'Student';
            _profileImageUrl = data['profileImageUrl'];
          });
        }
      } catch (e) {
        debugPrint("Error loading student profile: $e");
      }
    }
  }

  Future<void> _countInternships() async {
    try {
      final snapshot = await _firestore
          .collection('jobs')
          .where('jobType', isEqualTo: 'Internship')
          .where('isActive', isEqualTo: true)
          .get();
      setState(() {
        _internshipCount = snapshot.docs.length;
      });
    } catch (e) {
      debugPrint("Error counting internships: $e");
    }
  }
  Future<void> _countCourses() async {
    try {
      // Assuming your courses are stored in a 'courses' collection
      final snapshot = await _firestore.collection('courses').get();
      if (mounted) {
        setState(() {
          _courseCount = snapshot.docs.length;
        });
      }
    } catch (e) {
      debugPrint("Error counting courses: $e");
    }
  }

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
                              '$_studentName.',
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
                                backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                                    ? NetworkImage(_profileImageUrl!)
                                    : null,
                                child: _profileImageUrl == null || _profileImageUrl!.isEmpty
                                    ? Text(
                                        _studentName.isNotEmpty ? _studentName[0].toUpperCase() : 'S',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
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

                    // Quick Actions Row
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
                                    '$_courseCount',
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
                                    '$_internshipCount+', // Dynamically count internships
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

                    // LIVE INTERNSHIPS FEED
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('jobs')
                          .where('jobType', isEqualTo: 'Internship')
                          .where('isActive', isEqualTo: true)
                          .limit(5) // Just show the top 5 on the home screen
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(child: Text('Failed to load internships'));
                        }

                        final internships = snapshot.data?.docs ?? [];

                        if (internships.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                            child: Text(
                              'No internships available right now.',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: internships.length,
                          itemBuilder: (context, index) {
                            final jobData = internships[index].data() as Map<String, dynamic>;
                            final fullJobData = {'id': internships[index].id, ...jobData};

                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
                              child: _InternshipCard(
                                title: jobData['title'] ?? 'Internship',
                                company: jobData['companyName'] ?? 'Unknown Company',
                                location: jobData['location'] ?? 'Location unknown',
                                type: jobData['workplaceType'] ?? 'On-site',
                                jobType: jobData['jobType'] ?? 'Internship',
                                onTap: () => context.push('/student/job-detail', extra: fullJobData),
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