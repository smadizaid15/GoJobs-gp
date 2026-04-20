import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/job_service.dart';

class CompanyAddJobScreen extends StatefulWidget {
  const CompanyAddJobScreen({super.key});

  @override
  State<CompanyAddJobScreen> createState() => _CompanyAddJobScreenState();
}

class _CompanyAddJobScreenState extends State<CompanyAddJobScreen> {
  String? _jobPosition;
  String? _workplaceType;
  String? _jobLocation;
  String? _employmentType;
  final _descriptionController = TextEditingController();
  bool _isPosting = false;
  final JobService _jobService = JobService();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handlePostJob() async {
    if (_jobPosition == null ||
        _workplaceType == null ||
        _jobLocation == null ||
        _employmentType == null ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await _jobService.postJob(
        companyId: authProvider.user!.uid,
        companyName: 'Calma Space',
        title: _jobPosition!,
        location: _jobLocation!,
        workplaceType: _workplaceType!,
        employmentType: _employmentType!,
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/company/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post job: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.close,
                        color: AppColors.textPrimary),
                  ),
                  Text(
                    'Add a job',
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _isPosting ? null : _handlePostJob,
                    child: _isPosting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.companyGold,
                            ),
                          )
                        : Text(
                            'Post',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.companyGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Column(
                  children: [
                    _JobFormItem(
                      label: 'Job position*',
                      value: _jobPosition,
                      onTap: () async {
                        final result = await context
                            .push<String>('/company/job-position-picker');
                        if (result != null) {
                          setState(() => _jobPosition = result);
                        }
                      },
                    ),

                    _JobFormItem(
                      label: 'Type of workplace',
                      value: _workplaceType,
                      onTap: () async {
                        final result = await context
                            .push<String>('/company/workplace-type');
                        if (result != null) {
                          setState(() => _workplaceType = result);
                        }
                      },
                    ),

                    _JobFormItem(
                      label: 'Job location',
                      value: _jobLocation,
                      onTap: () async {
                        final result = await context
                            .push<String>('/company/location-picker');
                        if (result != null) {
                          setState(() => _jobLocation = result);
                        }
                      },
                    ),

                    _JobFormItem(
                      label: 'Employment type',
                      value: _employmentType,
                      onTap: () async {
                        final result =
                            await context.push<String>('/company/job-type');
                        if (result != null) {
                          setState(() => _employmentType = result);
                        }
                      },
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                // AI Generate button
             Align(
               alignment: Alignment.centerRight,
               child: GestureDetector(
               onTap: () => context.push('/ai-job-description'),
               child: Container(
                 padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingXS,
                ),
      decoration: BoxDecoration(
        color: AppColors.companyGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: AppColors.companyGold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.smart_toy_outlined,
            color: AppColors.companyGold,
            size: 14,
          ),
          const SizedBox(width: AppDimensions.paddingXS),
          Text(
            'Generate with AI',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.companyGold,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  ),
),
const SizedBox(height: AppDimensions.paddingXS),
                    
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Description',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Container(
                      height: 120,
                      padding:
                          const EdgeInsets.all(AppDimensions.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Write job description here...',
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobFormItem extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _JobFormItem({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingM,
          horizontal: AppDimensions.paddingS,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (value != null)
                  Text(
                    value!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const Icon(
              Icons.add,
              color: AppColors.companyGold,
            ),
          ],
        ),
      ),
    );
  }
}