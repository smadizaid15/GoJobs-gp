import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/jobseeker_bottom_nav.dart';
import '../../../services/job_service.dart';
import '../../../models/job_model.dart';
import '../../../providers/auth_provider.dart';

class JobseekerHomeScreen extends StatelessWidget {
  const JobseekerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final jobService = JobService();

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
                              '${authProvider.user?.displayName ?? 'User'}.',
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
                              onTap: () => context.go('/jobseeker/settings'),
                              child: const Icon(
                                Icons.settings_outlined,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingS),
                            GestureDetector(
                              onTap: () => context.go('/jobseeker/profile'),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primaryNavy,
                                child: Text(
                                  authProvider.user?.displayName?.isNotEmpty == true
                                      ? authProvider.user!.displayName![0].toUpperCase()
                                      : 'Z',
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

                    // Search bar
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.menu,
                              color: AppColors.textSecondary),
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
                          const Icon(Icons.search,
                              color: AppColors.textSecondary),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Recent job list
                    Text(
                      'Recent Job List',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    // Real jobs from Firestore
                    StreamBuilder<List<JobModel>>(
                      stream: jobService.getActiveJobs(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        final jobs = snapshot.data ?? [];

                        if (jobs.isEmpty) {
                          return Center(
                            child: Text(
                              'No jobs available yet',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: jobs
                              .take(3)
                              .map((job) => Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: AppDimensions.paddingM),
                                    child: _JobCard(
                                      title: job.title,
                                      company: job.companyName,
                                      location: job.location,
                                      type: job.workplaceType,
                                      jobType: job.employmentType,
                                      onTap: () => context
                                          .push('/jobseeker/job-detail'),
                                      onSave: () {},
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Find Your Job/Course section
                    Text(
                      'Find Your Job/Course',
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
                            onTap: () => context.go('/jobseeker/search'),
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
                                  const Icon(Icons.work_outline,
                                      color: Colors.white),
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
                                    'Jobs/Internships',
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
                            onTap: () => context.go('/jobseeker/search'),
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
                                  const Icon(Icons.school_outlined,
                                      color: Colors.white),
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

                    // Service providers banner
                    GestureDetector(
                      onTap: () =>
                          context.go('/jobseeker/service-providers'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusL,
                          ),
                          border: Border.all(color: AppColors.primaryOrange),
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
                              'Press here to uncover the world of freelancers and the variety of services they have to offer',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),
                  ],
                ),
              ),
            ),

            const JobseekerBottomNav(currentIndex: 0),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final String type;
  final String jobType;
  final VoidCallback onTap;
  final VoidCallback onSave;

  const _JobCard({
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.jobType,
    required this.onTap,
    required this.onSave,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: onSave,
                  child: const Icon(
                    Icons.bookmark_border,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
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
                _Tag(label: jobType),
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