import 'dart:typed_data'; 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; 

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class JobseekerUploadCvScreen extends StatefulWidget {
  final Map<String, dynamic>? job;

  const JobseekerUploadCvScreen({super.key, this.job});

  @override
  State<JobseekerUploadCvScreen> createState() => _JobseekerUploadCvScreenState();
}

class _JobseekerUploadCvScreenState extends State<JobseekerUploadCvScreen> {

  Uint8List? _cvBytes;
  String? _cvFileName;
  bool _isSubmitting = false;
  
  final TextEditingController _infoController = TextEditingController();

  Future<void> _pickCvFile() async {
    try {
      fp.FilePickerResult? result = await fp.FilePicker.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true, 
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _cvBytes = result.files.single.bytes;
          _cvFileName = result.files.single.name;
        });
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  Future<void> _submitApplication() async {
    if (_cvBytes == null || _cvFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your CV first!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    setState(() => _isSubmitting = true);

    try {
     
      final String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$_cvFileName';
      
     
      final storageRef = FirebaseStorage.instance.ref().child('cvs/$currentUserId/$uniqueFileName');

     
      final uploadTask = await storageRef.putData(_cvBytes!);
      final secureUrl = await uploadTask.ref.getDownloadURL();

      
      await FirebaseFirestore.instance.collection('applications').add({
        'jobId': widget.job?['id'] ?? 'unknown_job',
        'companyId': widget.job?['companyId'] ?? 'unknown_company',
        'applicantId': currentUserId,
        'message': _infoController.text,
        'cvFileName': _cvFileName, 
        'cvUrl': secureUrl, 
        'hasCv': true,                
        'appliedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
  
await FirebaseFirestore.instance.collection('notifications').add({
  'recipientId': widget.job?['companyId'] ?? 'unknown_company', 
  'type': 'application',
  'title': 'New Application',
  'subtitle': '${FirebaseAuth.instance.currentUser?.displayName ?? 'A user'} applied for your ${widget.job?['title'] ?? 'job'} position.',
  'actionLabel': 'View Applicant',
  'route': '/company/applicants', 
  'isRead': false,
  'createdAt': FieldValue.serverTimestamp(),
});

      if (mounted) {
        context.push('/jobseeker/application-success', extra: widget.job);
      }

    } catch (e) {
      print('Error submitting application: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _infoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.job?['title'] ?? 'Head Manager';
    final company = widget.job?['companyName'] ?? 'Calma Space';
    final location = widget.job?['location'] ?? 'Irbid';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Center(
                child: Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXS),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(location, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    const Text(' • '),
                    Text(company, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
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
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickCvFile,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.upload_outlined, color: AppColors.textSecondary),
                            const SizedBox(height: AppDimensions.paddingXS),
                            Text(
                              'Upload CV/\nResume',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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
                      onTap: _pickCvFile,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.purpleButton,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(color: AppColors.purpleButtonBorder),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.folder_outlined, color: AppColors.primaryNavy),
                            const SizedBox(height: AppDimensions.paddingXS),
                            Text(
                              'Use existing /\nadded CV',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryNavy),
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

              if (_cvFileName != null) ...[
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
                            Text(
                              _cvFileName ?? 'CV Document',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                        onTap: () => setState(() {
                          _cvBytes = null;
                          _cvFileName = null;
                        }),
                        child: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingL),
              ],

              Text(
                'Information(optional)',
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
                  controller: _infoController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Explain why you are the right person for this job',
                    hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    border: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitApplication,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
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
