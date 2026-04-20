import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class JobseekerWorkExperienceScreen extends StatefulWidget {
  const JobseekerWorkExperienceScreen({super.key});

  @override
  State<JobseekerWorkExperienceScreen> createState() =>
      _JobseekerWorkExperienceScreenState();
}

class _JobseekerWorkExperienceScreenState
    extends State<JobseekerWorkExperienceScreen> {
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isCurrentPosition = false;

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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

              //go back 
              GestureDetector(
                onTap: () => context.go('/jobseeker/profile'),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              Text(
                'Add work experience',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Job title
              Text('Job title', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(controller: _jobTitleController),

              const SizedBox(height: AppDimensions.paddingM),

              // Company
              Text('Company', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(controller: _companyController),

              const SizedBox(height: AppDimensions.paddingM),

              // Start and End date
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start date',
                            style: AppTextStyles.labelText),
                        const SizedBox(
                            height: AppDimensions.paddingXS),
                        TextField(
                            controller: _startDateController),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('End date',
                            style: AppTextStyles.labelText),
                        const SizedBox(
                            height: AppDimensions.paddingXS),
                        TextField(controller: _endDateController),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Current position 
              Row(
                children: [
                  Checkbox(
                    value: _isCurrentPosition,
                    activeColor: AppColors.primaryNavy,
                    onChanged: (val) => setState(
                        () => _isCurrentPosition = val ?? false),
                  ),
                  Text(
                    'This is my position now',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Description
              Text('Description', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              Container(
                height: 120,
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Write additional information here',
                    hintStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Save 
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () =>
                      context.go('/jobseeker/profile'),
                  child: Text('SAVE',
                      style: AppTextStyles.buttonText),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Remove 
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: OutlinedButton(
                  onPressed: () =>
                      context.go('/jobseeker/profile'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: AppColors.purpleButtonBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusL),
                    ),
                    backgroundColor: AppColors.purpleButton,
                  ),
                  child: Text(
                    'REMOVE',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
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
