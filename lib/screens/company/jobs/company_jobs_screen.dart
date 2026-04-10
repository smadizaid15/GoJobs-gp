import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/company_bottom_nav.dart';
import '../../../services/job_service.dart';
import '../../../models/job_model.dart';
import '../../../providers/auth_provider.dart';

class CompanyJobsScreen extends StatelessWidget {
  const CompanyJobsScreen({super.key});

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
              child: Column(
                children: [
                  const SizedBox(height: AppDimensions.paddingL),

                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/company/home'),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Jobs',
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/company/add-job'),
                          child: const Icon(
                            Icons.add,
                            color: AppColors.companyGold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingL),

                  // Real jobs from Firestore
                  Expanded(
                    child: StreamBuilder<List<JobModel>>(
                      stream: jobService.getCompanyJobs(
                          authProvider.user?.uid ?? ''),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final jobs = snapshot.data ?? [];

                        if (jobs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.work_off_outlined,
                                  color: AppColors.textSecondary,
                                  size: 60,
                                ),
                                const SizedBox(height: AppDimensions.paddingM),
                                Text(
                                  'No jobs posted yet',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.paddingM),
                                ElevatedButton(
                                  onPressed: () =>
                                      context.push('/company/add-job'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.companyGold,
                                  ),
                                  child: Text(
                                    'Post a Job',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingL,
                          ),
                          itemCount: jobs.length,
                          itemBuilder: (context, index) {
                            final job = jobs[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppDimensions.paddingM),
                              child: _JobCard(
                                title: job.title,
                                location: job.location,
                                status: job.isActive ? 'Active' : 'Closed',
                                onTap: () =>
                                    context.push('/company/applicants'),
                                onDelete: () async {
                                  await jobService.deleteJob(job.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Job deleted'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const CompanyBottomNav(currentIndex: -1),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String location;
  final String status;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _JobCard({
    required this.title,
    required this.location,
    required this.status,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'Active';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
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
                    location,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.companyGold.withValues(alpha: 0.15)
                        : AppColors.inputFill,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isActive
                          ? AppColors.companyGold
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingS),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}