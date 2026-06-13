import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class StudentUploadCvScreen extends StatefulWidget {
  final Map<String, dynamic>? jobData;

  const StudentUploadCvScreen({super.key, this.jobData});

  @override
  State<StudentUploadCvScreen> createState() => _StudentUploadCvScreenState();
}

class _StudentUploadCvScreenState extends State<StudentUploadCvScreen> {
  bool _hasUploadedCv = false;
  bool _isApplying = false;

  Future<void> _submitApplication() async {
    final user = FirebaseAuth.instance.currentUser;
    final jobId = widget.jobData?['id'];

    if (user == null || jobId == null) return;

    setState(() => _isApplying = true);

    try {
      // 1. Fetch user data to attach to the application
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['fullName'] ?? userDoc.data()?['displayName'] ?? 'Student';

      // 2. Create the application document
      await FirebaseFirestore.instance.collection('applications').add({
        'userId': user.uid,
        'userName': userName,
        'jobId': jobId,
        'jobTitle': widget.jobData?['title'] ?? 'Internship',
        'companyName': widget.jobData?['companyName'] ?? 'Company',
        'location': widget.jobData?['location'] ?? 'Location',
        'logoUrl': widget.jobData?['logoUrl'],
        'status': 'Pending',
        'appliedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Pass the job data forward to the success screen
        context.pushReplacement('/student/application-success', extra: widget.jobData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to apply: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.jobData ?? {};
    final title = data['title']?.toString() ?? 'Internship';
    final company = data['companyName']?.toString() ?? 'Company';
    final location = data['location']?.toString() ?? 'Location';
    final logoUrl = data['logoUrl']?.toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.paddingL),

              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Company logo
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        image: logoUrl != null 
                            ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover)
                            : null,
                      ),
                      child: logoUrl == null 
                          ? const Icon(Icons.business, color: AppColors.textSecondary, size: 40)
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

              const SizedBox(height: AppDimensions.paddingM),

              // Job title
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

              const SizedBox(height: AppDimensions.paddingXS),

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
                    const Text(' • '),
                    Text(
                      'Just now',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              Text(
                'Upload CV',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXS),

              Text(
                'Add your CV/Resume to apply for a job',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Upload options
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _hasUploadedCv = true),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(
                            color: AppColors.divider,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.upload_outlined,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: AppDimensions.paddingXS),
                            Text(
                              'Upload CV/\nResume',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppDimensions.paddingM),

                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _hasUploadedCv = true),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.purpleButton,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(
                            color: AppColors.purpleButtonBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.folder_outlined,
                              color: AppColors.primaryNavy,
                            ),
                            const SizedBox(height: AppDimensions.paddingXS),
                            Text(
                              'Use existing /\nadded CV',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primaryNavy,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Uploaded CV preview
              if (_hasUploadedCv) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.purpleButton,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(color: AppColors.purpleButtonBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                        size: 32,
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My_Resume.pdf',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Ready to submit',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _hasUploadedCv = false),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingL),
              ],

              Text(
                'Information (optional)',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingS),

              Container(
                width: double.infinity,
                height: 120,
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Explain why you are the right person for this job',
                    hintStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Apply button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_hasUploadedCv) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please upload your CV first!'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    _submitApplication();
                  },
                  child: _isApplying 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('APPLY NOW', style: AppTextStyles.buttonText),
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