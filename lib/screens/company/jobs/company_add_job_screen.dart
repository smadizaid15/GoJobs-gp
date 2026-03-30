import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

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

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
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
                    child: const Icon(Icons.close, color: AppColors.textPrimary),
                  ),
                  Text(
                    'Add a job',
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/company/home'),
                    child: Text(
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
                    // Job position
                    _JobFormItem(
                      label: 'Job position*',
                      value: _jobPosition,
                      onTap: () async {
                        final result = await context.push<String>(
                            '/company/job-position-picker');
                        if (result != null) {
                          setState(() => _jobPosition = result);
                        }
                      },
                    ),

                    // Type of workplace
                    _JobFormItem(
                      label: 'Type of workplace',
                      value: _workplaceType,
                      onTap: () async {
                        final result = await context.push<String>(
                            '/company/workplace-type');
                        if (result != null) {
                          setState(() => _workplaceType = result);
                        }
                      },
                    ),

                    // Job location
                    _JobFormItem(
                      label: 'Job location',
                      value: _jobLocation,
                      onTap: () async {
                        final result = await context.push<String>(
                            '/company/location-picker');
                        if (result != null) {
                          setState(() => _jobLocation = result);
                        }
                      },
                    ),

                    // Employment type
                    _JobFormItem(
                      label: 'Employment type',
                      value: _employmentType,
                      onTap: () async {
                        final result = await context.push<String>(
                            '/company/job-type');
                        if (result != null) {
                          setState(() => _employmentType = result);
                        }
                      },
                    ),

                    // Description
                    const SizedBox(height: AppDimensions.paddingM),
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
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
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