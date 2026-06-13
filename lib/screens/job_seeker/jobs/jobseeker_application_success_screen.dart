import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

// Changed to StatefulWidget to fetch the real CV name from Firebase
class JobseekerApplicationSuccessScreen extends StatefulWidget {
  final Map<String, dynamic>? job;

  const JobseekerApplicationSuccessScreen({super.key, this.job});

  @override
  State<JobseekerApplicationSuccessScreen> createState() => _JobseekerApplicationSuccessScreenState();
}

class _JobseekerApplicationSuccessScreenState extends State<JobseekerApplicationSuccessScreen> {
  String _actualCvName = 'Loading CV...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRealApplicationDetails();
  }

 Future<void> _fetchRealApplicationDetails() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      // THE FIX: Adding the safety net
      final currentJobId = widget.job?['id'] ?? 'unknown_job';

      if (currentUserId != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('applications')
            .where('applicantId', isEqualTo: currentUserId)
            .where('jobId', isEqualTo: currentJobId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          // Sorting protects us from pulling an older test application
          final docs = snapshot.docs;
          docs.sort((a, b) {
            final aTime = a.data()['appliedAt'] as Timestamp?;
            final bTime = b.data()['appliedAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime); 
          });

          setState(() {
            _actualCvName = docs.first.data()['cvFileName']?.toString() ?? 'My_Resume.pdf';
            _isLoading = false;
          });
          return;
        }
      }
      
      setState(() {
        _actualCvName = 'No CV Found';
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching application: $e');
      setState(() {
        _actualCvName = 'Error Loading CV';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.job?['title'] ?? 'Head Manager';
    final company = widget.job?['companyName'] ?? 'Calma Space';
    final location = widget.job?['location'] ?? 'Irbid';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.paddingL),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  ),
                  const Icon(Icons.more_vert, color: AppColors.textPrimary),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingL),

              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                      ),
                      child: const Icon(Icons.business, color: AppColors.textSecondary, size: 40),
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

              const SizedBox(height: AppDimensions.paddingM),

              Text(
                title,
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXS),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(location,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                  const Text(' • '),
                  Text(company,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingL),

              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.purpleButton,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.purpleButtonBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _isLoading
                              ? const SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textSecondary),
                                )
                              : Text(
                                  _actualCvName,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          Text(
                            'Submitted successfully',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              const Icon(
                Icons.check_circle_outline,
                color: AppColors.primaryOrange,
                size: 80,
              ),

              const SizedBox(height: AppDimensions.paddingM),

              Text(
                'Successful',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXS),

              Text(
                'Congratulations, your application has been sent',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: OutlinedButton(
                  onPressed: () => context.go(
                      '/jobseeker/my-application',
                      extra: widget.job),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.purpleButtonBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    backgroundColor: AppColors.purpleButton,
                  ),
                  child: Text(
                    'VIEW APPLICATION',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => context.go('/jobseeker/home'),
                  child: Text('BACK TO HOME', style: AppTextStyles.buttonText),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),
            ],
          ),
        ),
      ),
    );
  }
}