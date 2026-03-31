import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class FreelancerExpertiseScreen extends StatefulWidget {
  const FreelancerExpertiseScreen({super.key});

  @override
  State<FreelancerExpertiseScreen> createState() =>
      _FreelancerExpertiseScreenState();
}

class _FreelancerExpertiseScreenState
    extends State<FreelancerExpertiseScreen> {
  final _serviceTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shiftStartController = TextEditingController();
  final _shiftEndController = TextEditingController();
  final _additionalController = TextEditingController();
  bool _isOpen24_7 = false;

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _descriptionController.dispose();
    _shiftStartController.dispose();
    _shiftEndController.dispose();
    _additionalController.dispose();
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
                onTap: () => context.go('/freelancer/profile'),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              Text(
                'Add Expertise',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              Text('What type of services do you provide',
                  style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(controller: _serviceTypeController),

              const SizedBox(height: AppDimensions.paddingM),

              Text('Description of what you do',
                  style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(controller: _descriptionController),

              const SizedBox(height: AppDimensions.paddingM),

              // Shift times
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Shift Start',
                            style: AppTextStyles.labelText),
                        const SizedBox(
                            height: AppDimensions.paddingXS),
                        TextField(
                            controller: _shiftStartController),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Shift end',
                            style: AppTextStyles.labelText),
                        const SizedBox(
                            height: AppDimensions.paddingXS),
                        TextField(controller: _shiftEndController),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Open 24/7 toggle
              Row(
                children: [
                  Switch(
                    value: _isOpen24_7,
                    onChanged: (val) =>
                        setState(() => _isOpen24_7 = val),
                    activeColor: AppColors.primaryNavy,
                  ),
                  Text(
                    'open to work 24/7',
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
                  controller: _additionalController,
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
                  onPressed: () =>
                      context.go('/freelancer/profile'),
                  child: Text('SAVE',
                      style: AppTextStyles.buttonText),
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