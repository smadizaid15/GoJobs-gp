import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/student_bottom_nav.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(AppDimensions.radiusXL),
                          bottomRight: Radius.circular(AppDimensions.radiusXL),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top icons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => context.go('/student/home'),
                                child: const Icon(
                                  Icons.share_outlined,
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/student/settings'),
                                child: const Icon(
                                  Icons.settings_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          // Profile pic
                          Align(
                            alignment: Alignment.centerLeft,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.inputFill,
                              child: Text(
                                'Z',
                                style: AppTextStyles.heading2.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          Text(
                            'Zaid Smadi.',
                            style: AppTextStyles.heading3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),

                          Text(
                            'Jordan',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.left,
                          ),

                          Text(
                            'University of science and technology',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.left,
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          // Edit profile button
                          GestureDetector(
                            onTap: () => context.go('/student/edit-profile'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingL,
                                vertical: AppDimensions.paddingXS,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull,
                                ),
                                border: Border.all(color: Colors.white54),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Edit profile',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.paddingXS),
                                  const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Profile info form
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () => context.go('/student/home'),
                            child: const Icon(
                              Icons.arrow_back,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          Text('Fullname', style: AppTextStyles.labelText),
                          const SizedBox(height: AppDimensions.paddingXS),
                          _ProfileField(value: 'Zaid smadi'),

                          const SizedBox(height: AppDimensions.paddingM),

                          Text('Date of birth', style: AppTextStyles.labelText),
                          const SizedBox(height: AppDimensions.paddingXS),
                          _ProfileField(
                            value: '24 October 2004',
                            trailing: const Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          Text('Gender', style: AppTextStyles.labelText),
                          const SizedBox(height: AppDimensions.paddingXS),
                          Row(
                            children: [
                              _GenderOption(label: 'Male', isSelected: true),
                              const SizedBox(width: AppDimensions.paddingM),
                              _GenderOption(label: 'Female', isSelected: false),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          Text('Email address', style: AppTextStyles.labelText),
                          const SizedBox(height: AppDimensions.paddingXS),
                          _ProfileField(value: 'smadizaid15@gmail.com'),

                          const SizedBox(height: AppDimensions.paddingM),

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
                                    Text('962+', style: AppTextStyles.bodySmall),
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingS),
                              Expanded(
                                child: _ProfileField(value: '798350308'),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          Text('University', style: AppTextStyles.labelText),
                          const SizedBox(height: AppDimensions.paddingXS),
                          _ProfileField(
                            value: 'Jordan university of science and technology',
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          Text('Major', style: AppTextStyles.labelText),
                          const SizedBox(height: AppDimensions.paddingXS),
                          _ProfileField(value: 'Computer Science'),

                          const SizedBox(height: AppDimensions.paddingXL),

                          // Save button
                          SizedBox(
                            width: double.infinity,
                            height: AppDimensions.buttonHeight,
                            child: ElevatedButton(
                              onPressed: () => context.go('/student/home'),
                              child: Text(
                                'SAVE',
                                style: AppTextStyles.buttonText,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppDimensions.paddingXL),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const StudentBottomNav(currentIndex: -1),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String value;
  final Widget? trailing;

  const _ProfileField({required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingM,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: AppTextStyles.bodyMedium),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _GenderOption({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}