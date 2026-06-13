import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/company_bottom_nav.dart';
import '../../../services/job_service.dart';
import '../../../models/job_model.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _jobService = JobService();

  
  Future<void> _toggleJobStatus(String jobId, bool isNowActive) async {
    try {
      await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
        'isActive': isNowActive,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating job status: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                   
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            width: double.infinity,
                            height: 250,
                            color: AppColors.primaryNavy,
                            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                          );
                        }

                        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                        final companyName = data['companyName']?.toString() ?? 'Your Company';
                        final location = data['location']?.toString() ?? 'Location not set';
                        final logoUrl = data['logoUrl']?.toString();

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primaryNavy, Color(0xFF1a1850)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(AppDimensions.radiusXL),
                              bottomRight: Radius.circular(AppDimensions.radiusXL),
                            ),
                          ),
                          child: Column(
                            children: [
                             
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => context.go('/company/home'),
                                    child: const Icon(Icons.share_outlined, color: Colors.white),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.go('/company/settings'),
                                    child: const Icon(Icons.settings_outlined, color: Colors.white),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                              
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                                  child: logoUrl != null && logoUrl.isNotEmpty
                                      ? Image.network(
                                          logoUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.business, size: 40, color: AppColors.textSecondary),
                                        )
                                      : Image.asset(
                                          'assets/images/company_logo.png',
                                          fit: BoxFit.contain,
                                        ),
                                ),
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                              
                              Text(
                                companyName,
                                style: AppTextStyles.heading3.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                location,
                                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                             
                              GestureDetector(
                                onTap: () => context.go('/company/edit-profile'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.paddingL,
                                    vertical: AppDimensions.paddingXS,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                    border: Border.all(color: Colors.white54),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Edit profile',
                                        style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                                      ),
                                      const SizedBox(width: AppDimensions.paddingXS),
                                      const Icon(Icons.edit_outlined, color: Colors.white, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                   
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
                                  decoration: BoxDecoration(
                                    color: AppColors.companyGold,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Posted and active jobs',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingS),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => context.go('/company/applicants'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryNavy,
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Applicants',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                        
                          StreamBuilder<List<JobModel>>(
                            stream: _jobService.getCompanyJobs(currentUserId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.all(AppDimensions.paddingL),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }

                              final jobs = snapshot.data ?? [];

                              if (jobs.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXL),
                                  child: Center(
                                    child: Text(
                                      'No jobs posted yet.',
                                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: jobs.length,
                                itemBuilder: (context, index) {
                                  final job = jobs[index];
                                  return _JobItem(
                                    title: job.title,
                                    isChecked: job.isActive,
                                    onToggle: (bool newValue) {
                                      _toggleJobStatus(job.id, newValue);
                                    },
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: AppDimensions.paddingL),

                      
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context.go('/company/add-job'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.companyGold),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                    ),
                                  ),
                                  child: Text(
                                    'POST NEW', 
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.companyGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingM),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context.go('/company/jobs'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.companyGold),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                    ),
                                  ),
                                  child: Text(
                                    'MANAGE JOBS',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.companyGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.paddingXL),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const CompanyBottomNav(currentIndex: 1),
          ],
        ),
      ),
    );
  }
}

class _JobItem extends StatelessWidget {
  final String title;
  final bool isChecked;
  final Function(bool) onToggle;

  const _JobItem({
    required this.title,
    required this.isChecked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Checkbox(
            value: isChecked,
            activeColor: AppColors.companyGold,
            onChanged: (val) {
              if (val != null) {
                onToggle(val);
              }
            },
          ),
        ],
      ),
    );
  }
}