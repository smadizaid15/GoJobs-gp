import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class JobseekerFilterScreen extends StatefulWidget {
  const JobseekerFilterScreen({super.key});

  @override
  State<JobseekerFilterScreen> createState() => _JobseekerFilterScreenState();
}

class _JobseekerFilterScreenState extends State<JobseekerFilterScreen> {
  String _selectedCategory = 'Design';
  String _selectedSubCategory = 'UI/UX Design';
  String _selectedLocation = 'Irbid';
  RangeValues _salaryRange = const RangeValues(500, 750);
  String _selectedJobType = 'Full time';

  final List<String> _jobTypes = ['Full time', 'Part time', 'Remote'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.paddingL),

              // Back + title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Text(
                    'Filter',
                    style: AppTextStyles.heading2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Category
              _FilterSection(
                title: 'Category',
                isExpanded: true,
                child: Text(
                  _selectedCategory,
                  style: AppTextStyles.bodyMedium,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Sub Category
              _FilterSection(
                title: 'Sub Category',
                isExpanded: false,
                child: Text(
                  _selectedSubCategory,
                  style: AppTextStyles.bodyMedium,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Location
              _FilterSection(
                title: 'Location',
                isExpanded: false,
                child: Text(
                  _selectedLocation,
                  style: AppTextStyles.bodyMedium,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Salary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Minimum Salary',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Minimum Salary',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              _FilterSection(
                title: 'Salary',
                isExpanded: true,
                child: Column(
                  children: [
                    RangeSlider(
                      values: _salaryRange,
                      min: 0,
                      max: 2000,
                      activeColor: AppColors.primaryOrange,
                      inactiveColor: AppColors.divider,
                      onChanged: (values) {
                        setState(() => _salaryRange = values);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${_salaryRange.start.toInt()}',
                          style: AppTextStyles.bodySmall,
                        ),
                        Text(
                          '\$${_salaryRange.end.toInt()}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Job Type
              Text(
                'Job Type',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingS),

              Row(
                children: _jobTypes.map((type) {
                  final isSelected = _selectedJobType == type;
                  return Padding(
                    padding: const EdgeInsets.only(
                        right: AppDimensions.paddingS),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedJobType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryNavy
                              : Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryNavy
                                : AppColors.divider,
                          ),
                        ),
                        child: Text(
                          type,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Search button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  child: Text('SEARCH', style: AppTextStyles.buttonText),
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

class _FilterSection extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final Widget child;

  const _FilterSection({
    required this.title,
    required this.isExpanded,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingS),
        child,
        const Divider(color: AppColors.divider),
      ],
    );
  }
}