import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class JobseekerEditProfileScreen extends StatefulWidget {
  const JobseekerEditProfileScreen({super.key});

  @override
  State<JobseekerEditProfileScreen> createState() =>
      _JobseekerEditProfileScreenState();
}

class _JobseekerEditProfileScreenState
    extends State<JobseekerEditProfileScreen> {
  final _nameController =
      TextEditingController(text: 'Zaid smadi');
  final _dobController =
      TextEditingController(text: '24 October 2004');
  final _emailController =
      TextEditingController(text: 'smadizaid15@gmail.com');
  final _phoneController =
      TextEditingController(text: '798350308');
  final _locationController =
      TextEditingController(text: 'Irbid, Jordan');
  bool _isMale = true;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
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

              // Back button
              GestureDetector(
                onTap: () => context.go('/jobseeker/profile'),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Fullname
              Text('Fullname', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(controller: _nameController),

              const SizedBox(height: AppDimensions.paddingM),

              // Date of birth
              Text('Date of birth', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _dobController,
                decoration: const InputDecoration(
                  suffixIcon: Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Gender
              Text('Gender', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingS),
              Row(
                children: [
                  _GenderOption(
                    label: 'Male',
                    isSelected: _isMale,
                    onTap: () => setState(() => _isMale = true),
                  ),
                  const SizedBox(width: AppDimensions.paddingL),
                  _GenderOption(
                    label: 'Female',
                    isSelected: !_isMale,
                    onTap: () => setState(() => _isMale = false),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Email
              Text('Email address', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(controller: _emailController),

              const SizedBox(height: AppDimensions.paddingM),

              // Phone
              Text('Phone number', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                      vertical: AppDimensions.paddingM,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM),
                    ),
                    child: Row(
                      children: [
                        Text('962+',
                            style: AppTextStyles.bodySmall),
                        const Icon(Icons.keyboard_arrow_down,
                            size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingS),
                  Expanded(
                    child: TextField(controller: _phoneController),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Location
              Text('Location', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(controller: _locationController),

              const SizedBox(height: AppDimensions.paddingXL),

              // Save button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => context.go('/jobseeker/profile'),
                  child: Text('SAVE', style: AppTextStyles.buttonText),
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

class _GenderOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryOrange
                    : AppColors.textSecondary,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppDimensions.paddingXS),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}