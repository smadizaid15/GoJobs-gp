import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isSaving = false;

  Future<void> _saveExperience() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_jobTitleController.text.trim().isEmpty || _companyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in Job Title and Company'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final newExperience = {
        'jobTitle': _jobTitleController.text.trim(),
        'company': _companyController.text.trim(),
        'startDate': _startDateController.text.trim(),
        'endDate': _isCurrentPosition ? 'Present' : _endDateController.text.trim(),
        'description': _descriptionController.text.trim(),
        'isCurrent': _isCurrentPosition,
      };

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'experience': FieldValue.arrayUnion([newExperience]),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Experience added!'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

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

              
              GestureDetector(
                onTap: () => context.pop(),
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

              
              Text('Job title', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(controller: _jobTitleController),

              const SizedBox(height: AppDimensions.paddingM),

             
              Text('Company', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(controller: _companyController),

              const SizedBox(height: AppDimensions.paddingM),

              
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
                          controller: _startDateController,
                          decoration: const InputDecoration(hintText: 'MM/YYYY'),
                        ),
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
                        TextField(
                          controller: _endDateController,
                          enabled: !_isCurrentPosition,
                          decoration: InputDecoration(
                            hintText: _isCurrentPosition ? 'Present' : 'MM/YYYY',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingM),

             
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

              
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveExperience,
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('SAVE', style: AppTextStyles.buttonText),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

             
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
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
                    'CANCEL',
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