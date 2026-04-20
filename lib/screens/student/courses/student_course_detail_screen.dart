import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class StudentCourseDetailScreen extends StatelessWidget {
  const StudentCourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.paddingL),

              //go back 
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: GestureDetector(
                  onTap: () => context.go('/student/courses'),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Company logo and name
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Container(
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
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    const Center(
                      child: Text(
                        'Calma Space',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Course title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Data science with python',
                        style: AppTextStyles.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    // Location and type and price 
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Amman',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Text(' • '),
                          Text(
                            'On site',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Text(' • '),
                          Text(
                            'Free of charge',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    // View enterprise 
                    Center(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.purpleButtonBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          backgroundColor: AppColors.purpleButton,
                        ),
                        child: Text(
                          'View enterprise',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Course description
                    Text(
                      'Course Description',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    Text(
                      'Jumpstart your career in tech with this beginner-friendly Python bootcamp. Learn the absolute basics of programming, write your first scripts, and discover how Python is used in today\'s job market—no prior experience required!',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Read more',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // What you will learn
                    Text(
                      'What You Will Learn:',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    _LearnItem(
                      text:
                          'The Basics: Variables, data types, and how to write clean code.',
                    ),
                    _LearnItem(
                      text:
                          'Logic & Flow: If/else statements, loops, and functions to automate tasks',
                    ),
                    _LearnItem(
                      text:
                          'Real-World Application: How to read and write data to simple files.',
                    ),
                    _LearnItem(
                      text:
                          'Career Guidance: A brief overview of how Python is used in data science, web development, and AI to help you choose your next steps.',
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),

                    // Enroll button
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(
                            content: Text('Successfully enrolled!'),
                             backgroundColor: AppColors.primaryNavy,
                            ),
                          );
                        },
                        child: Text(
                          'ENROLL NOW',
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
    );
  }
}

class _LearnItem extends StatelessWidget {
  final String text;
  const _LearnItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.textPrimary)),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}