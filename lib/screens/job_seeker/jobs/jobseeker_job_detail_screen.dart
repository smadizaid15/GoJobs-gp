import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../services/job_service.dart';

class JobseekerJobDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? job;

  const JobseekerJobDetailScreen({super.key, this.job});

  @override
  Widget build(BuildContext context) {
    final jobId = job?['id'] ?? '';
    final title = job?['title'] ?? 'Head Manager';
    final company = job?['companyName'] ?? 'Calma Space';
    final location = job?['location'] ?? 'Irbid, Jordan';
    final workplaceType = job?['workplaceType'] ?? 'On-site';
    final employmentType = job?['employmentType'] ?? 'Full time';
    final description = job?['description'] ?? 'No description provided.';
    final companyLogo = job?['companyLogo']?.toString();
    
    // ---> NEW: Safely extract the photos array <---
    final List<String> jobImages = [];
    if (job?['jobImages'] != null) {
      jobImages.addAll(List<String>.from(job!['jobImages']));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.paddingL),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (jobId.isEmpty) return; 
                        final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
                        await JobService().toggleSavedJob(currentUserId, jobId);
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Saved to your profile!'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: const Icon(
                        Icons.bookmark_border,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        image: companyLogo != null && companyLogo.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(companyLogo),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: companyLogo == null || companyLogo.isEmpty
                          ? const Icon(
                              Icons.business,
                              color: AppColors.textSecondary,
                              size: 40,
                            )
                          : null,
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Text(
                      company,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        title,
                        style: AppTextStyles.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            location,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Text(' • '),
                          Text(
                            company,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    Center(
                      child: OutlinedButton(
                        onPressed: () => context.push('/jobseeker/company-profile', extra: job),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.purpleButtonBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull),
                          ),
                          backgroundColor: AppColors.purpleButton,
                        ),
                        child: Text(
                          'View company',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/ai-job-match', extra: job),
                        icon: const Icon(
                          Icons.smart_toy_outlined,
                          size: 16,
                          color: AppColors.primaryNavy,
                        ),
                        label: Text(
                          'Check Match Score',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.purpleButtonBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull),
                          ),
                          backgroundColor: AppColors.purpleButton,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingXS),

                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/ai-interview-prep', extra: job),
                        icon: const Icon(
                          Icons.record_voice_over_outlined,
                          size: 16,
                          color: AppColors.primaryNavy,
                        ),
                        label: Text(
                          'Interview Prep',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.purpleButtonBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull),
                          ),
                          backgroundColor: AppColors.purpleButton,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    Text(
                      'Job Description',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    // ---> NEW: PHOTO GALLERY UI <---
                    if (jobImages.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.paddingL),
                      Text(
                        'Workplace Photos',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingS),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: jobImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: AppDimensions.paddingM),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                image: DecorationImage(
                                  image: NetworkImage(jobImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: AppDimensions.paddingL),

                    Text(
                      'Location',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    Text(
                      location,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusL),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.map_outlined,
                          color: AppColors.textSecondary,
                          size: 48,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    Text(
                      'Informations',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    _InfoRow(label: 'Position', value: title),
                    _InfoRow(label: 'Location', value: location),
                    _InfoRow(label: 'Job Type', value: employmentType),
                    _InfoRow(label: 'Workplace Type', value: workplaceType),

                    const SizedBox(height: AppDimensions.paddingXL),

                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: () => context.push('/jobseeker/upload-cv', extra: job),
                        child: Text(
                          'APPLY NOW',
                          style: AppTextStyles.buttonText,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}