import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class CompanyApplicantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> application;

  const CompanyApplicantDetailScreen({super.key, required this.application});

  @override
  State<CompanyApplicantDetailScreen> createState() => _CompanyApplicantDetailScreenState();
}

class _CompanyApplicantDetailScreenState extends State<CompanyApplicantDetailScreen> {
  bool _isProcessing = false;

  Future<void> _openCvLink() async {
    final cvUrl = widget.application['cvUrl']?.toString();
    
    if (cvUrl == null || cvUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No CV link found for this applicant.')),
      );
      return;
    }

    try {
      final Uri url = Uri.parse(cvUrl);
      await launchUrl(url); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open file attachment link.')),
      );
    }
  }

  Future<void> _updateStatus(String status) async {
    final docId = widget.application['id']?.toString();
    if (docId == null) return;

    setState(() => _isProcessing = true);
    try {
      await FirebaseFirestore.instance.collection('applications').doc(docId).update({'status': status});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'accepted' ? 'Applicant accepted!' : 'Applicant rejected'),
            backgroundColor: status == 'accepted' ? Colors.green : AppColors.error,
          ),
        );
        context.pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    
    final userName = app['userName']?.toString() ?? 'Unknown';
    final jobTitle = app['jobTitle']?.toString() ?? 'Job';
    final message = app['message']?.toString();
    final cvFileName = app['cvFileName']?.toString() ?? 'Applicant_Resume.pdf';
    final cvUrl = app['cvUrl']?.toString();
    
    final appliedAt = app['appliedAt'] as Timestamp?;
    final dateString = appliedAt != null 
        ? DateFormat('dd MMM yyyy, hh:mm a').format(appliedAt.toDate()) 
        : 'Recently';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.paddingL),

              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryNavy,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: AppTextStyles.heading1.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    Text(
                      userName,
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text(
                      'Applied for: $jobTitle',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.companyGold),
                    ),
                    Text(
                      dateString,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              Text(
                'Cover Letter / Message',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  message != null && message.isNotEmpty ? message : 'No additional message provided by the applicant.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              Text(
                'Resume / CV',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              
              GestureDetector(
                onTap: _openCvLink,
                child: Container(
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
                            Text(
                              cvFileName,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              cvUrl != null ? 'Tap to view document' : 'No document attached',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (cvUrl != null)
                        const Icon(Icons.open_in_new, size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus('rejected'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          ),
                        ),
                        child: Text(
                          'REJECT',
                          style: AppTextStyles.buttonText.copyWith(color: AppColors.error),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateStatus('accepted'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          ),
                        ),
                        child: Text(
                          'ACCEPT',
                          style: AppTextStyles.buttonText.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: AppDimensions.paddingXL),
            ],
          ),
        ),
      ),
    );
  }
}