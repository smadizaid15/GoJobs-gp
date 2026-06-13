import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class JobseekerMyApplicationScreen extends StatefulWidget {
  final Map<String, dynamic>? job;

  const JobseekerMyApplicationScreen({super.key, this.job});

  @override
  State<JobseekerMyApplicationScreen> createState() => _JobseekerMyApplicationScreenState();
}

class _JobseekerMyApplicationScreenState extends State<JobseekerMyApplicationScreen> {
  String _actualCvName = 'Loading CV...';
  String? _actualCvUrl; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRealApplicationDetails();
  }

  Future<void> _fetchRealApplicationDetails() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      // THE FIX: We perfectly match the "unknown_job" safety net we used when saving
      final currentJobId = widget.job?['id'] ?? 'unknown_job'; 

      if (currentUserId != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('applications')
            .where('applicantId', isEqualTo: currentUserId)
            .where('jobId', isEqualTo: currentJobId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          // Sort the list in Dart to guarantee we grab the NEWEST application
          final docs = snapshot.docs;
          docs.sort((a, b) {
            final aTime = a.data()['appliedAt'] as Timestamp?;
            final bTime = b.data()['appliedAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime); 
          });

          final latestData = docs.first.data();
          
          setState(() {
            _actualCvName = latestData['cvFileName']?.toString() ?? 'My_Resume.pdf';
            _actualCvUrl = latestData['cvUrl']?.toString(); 
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

  Future<void> _openCvLink() async {
    if (_actualCvUrl == null || _actualCvUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No viewable link found for this CV.')),
      );
      return;
    }

    try {
      final Uri url = Uri.parse(_actualCvUrl!);
      // THE FIX: Removed external mode limit so Chrome web browser allows it to open safely
      await launchUrl(url); 
    } catch (e) {
      print('Error opening CV link: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open file attachment link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.job?['title'] ?? 'Head Manager';
    final company = widget.job?['companyName'] ?? 'Calma Space';
    final location = widget.job?['location'] ?? 'Irbid, Jordan';
    final employmentType = widget.job?['employmentType'] ?? 'Full time';
    final workplaceType = widget.job?['workplaceType'] ?? 'On-site';

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

              Text(
                'Your application',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: const Icon(Icons.business, color: AppColors.textSecondary, size: 30),
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

              Text(
                '$company • $location',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXS),

              Text(
                '• Application submitted',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              Text(
                'Job details',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingS),

              _DetailItem(text: title),
              _DetailItem(text: employmentType),
              _DetailItem(text: workplaceType),
              _DetailItem(text: location),

              const SizedBox(height: AppDimensions.paddingL),

              Text(
                'Application details',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingS),

              _DetailItem(text: 'CV/Resume'),

              const SizedBox(height: AppDimensions.paddingM),

              GestureDetector(
                onTap: _isLoading ? null : _openCvLink,
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
                              _actualCvUrl != null ? 'Tap to open document' : 'Submitted successfully',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_isLoading && _actualCvUrl != null)
                        const Icon(Icons.open_in_new, size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => context.go('/jobseeker/search'),
                  child: Text('APPLY FOR MORE JOBS', style: AppTextStyles.buttonText),
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

class _DetailItem extends StatelessWidget {
  final String text;
  const _DetailItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingXS),
      child: Row(
        children: [
          const Text('• ', style: TextStyle(color: AppColors.textPrimary)),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}