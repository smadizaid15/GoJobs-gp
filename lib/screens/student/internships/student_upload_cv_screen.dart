import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class StudentUploadCvScreen extends StatefulWidget {
  const StudentUploadCvScreen({super.key});

  @override
  State<StudentUploadCvScreen> createState() => _StudentUploadCvScreenState();
}

class _StudentUploadCvScreenState extends State<StudentUploadCvScreen> {
  bool _hasUploadedCv = false;

  @override
  Widget build(BuildContext context) {
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

              // Back button
              GestureDetector(
                onTap: () => context.go('/student/internship-detail'),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
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
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusL),
                      ),
                      child: const Icon(
                        Icons.business,
                        color: AppColors.textSecondary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Text(
                      'Calma Space',
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
                  'AI & Data Science Intern',
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
                    Text(
                      'Irbid',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Text(' • '),
                    Text(
                      'Calma Space',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Text(' • '),
                    Text(
                      '1 day ago',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Upload CV section
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
                  // Upload new CV
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _hasUploadedCv = true),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusM),
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

                  // Use existing CV
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _hasUploadedCv = true),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.purpleButton,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusM),
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
                'Zaid Kilany - CV - Head barista',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '867 Kb • 14 Feb 2022 at 11:30 am',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        // X button to remove file
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

              // Information optional
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
  context.go('/student/application-success');
},
                  child: Text(
                    'APPLY NOW',
                    style: AppTextStyles.buttonText,
                  ),
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
