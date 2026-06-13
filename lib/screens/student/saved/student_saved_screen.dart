import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/job_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/student_bottom_nav.dart';
import '../../../services/job_service.dart';


class StudentSavedScreen extends StatelessWidget {
  const StudentSavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final jobService = JobService();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F0F5),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Saved Items',
          style: AppTextStyles.heading3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: jobService.getSavedJobIds(currentUserId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy));
                  }

                  final savedJobIds = snapshot.data ?? [];

                  if (savedJobIds.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/nosavings.png',
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: AppDimensions.paddingXL),
                        Text(
                          'No Savings',
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingS),
                        Text(
                          "You don't have any items saved, please\nfind it in search to save items",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.paddingXL),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL),
                          child: SizedBox(
                            width: double.infinity,
                            height: AppDimensions.buttonHeight,
                            child: ElevatedButton(
                              onPressed: () {
                                context.go('/student/courses');
                              },
                              child: Text(
                                'FIND A JOB',
                                style: AppTextStyles.buttonText,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    itemCount: savedJobIds.length,
                    itemBuilder: (context, index) {
                      return _LiveSavedJobCard(
                        jobId: savedJobIds[index],
                        userId: currentUserId,
                        jobService: jobService,
                        isStudent: true, 
                      );
                    },
                  );
                },
              ),
            ),
            const StudentBottomNav(currentIndex: 4),
          ],
        ),
      ),
    );
  }
}

class _LiveSavedJobCard extends StatelessWidget {
  final String jobId;
  final String userId;
  final JobService jobService;
  final bool isStudent;

  const _LiveSavedJobCard({
    required this.jobId,
    required this.userId,
    required this.jobService,
    required this.isStudent,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: jobService.getLiveJobStream(jobId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final doc = snapshot.data!;
        
        if (!doc.exists) {
          return _DisabledJobCard(
            title: 'Unavailable',
            message: 'This posting was removed.',
            onRemove: () {
              jobService.toggleSavedJob(userId, jobId);
            },
          );
        }

        final jobData = doc.data() as Map<String, dynamic>;
        final isActive = jobData['isActive'] as bool? ?? false;

        if (!isActive) {
          return _DisabledJobCard(
            title: jobData['title']?.toString() ?? 'Closed',
            message: 'This position is no longer active.',
            onRemove: () {
              
              jobService.toggleSavedJob(userId, jobId);
            },
          );
        }

        return GestureDetector(
          onTap: () {
            final fullJobData = {'id': doc.id, ...jobData};
            final route = isStudent ? '/student/job-detail' : '/jobseeker/job-detail';
            context.push(route, extra: fullJobData);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: const Icon(Icons.business, color: AppColors.textSecondary),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jobData['title']?.toString() ?? 'Unknown Position',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${jobData['companyName']} • ${jobData['location']}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        jobData['salary']?.toString() ?? 'Salary unlisted',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    
                    jobService.toggleSavedJob(userId, jobId);
                  },
                  child: const Icon(
                    Icons.bookmark,
                    color: AppColors.companyGold,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DisabledJobCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRemove;

  const _DisabledJobCard({
    required this.title,
    required this.message,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.bookmark, color: Colors.grey, size: 24),
          ),
        ],
      ),
    );
  }
}