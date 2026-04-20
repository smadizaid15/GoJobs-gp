import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class StudentInternshipDetailScreen extends StatelessWidget {
  const StudentInternshipDetailScreen({super.key});

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
                  onTap: () => context.go('/student/internship-categories'),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Company logo and name
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

              const SizedBox(height: AppDimensions.paddingL),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Center(
                      child: Text(
                        'AI & Data Science Intern',
                        style: AppTextStyles.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    // Location and type and duration
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
                            '3 month internship',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    // View company 
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
                          'View Company',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Job description
                    Text(
                      'Job Description',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    Text(
                      'Kickstart your career in Artificial Intelligence! Join our core engineering team to help train predictive models, clean large datasets, and work on real-world pattern recognition algorithms. Perfect for current CS undergrads looking for hands-on industry experience',
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

                    // What you will do
                    Text(
                      'What you will do:',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    _BulletItem(text: 'Assist in preprocessing, cleaning, and structuring large datasets.'),
                    _BulletItem(text: 'Work alongside senior developers to train and test machine learning models using Python, scikit-learn, and pandas.'),
                    _BulletItem(text: 'Help optimize algorithms for pattern recognition and sequence analysis.'),
                    _BulletItem(text: 'Participate in weekly code reviews and architecture brainstorming sessions'),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Location
                    Text(
                      'Location',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    Text(
                      'Jordan, Amman, Business park',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    // Map placeholder
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusL),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.map_outlined,
                          color: AppColors.textSecondary,
                          size: 48,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Information
                    Text(
                      'Informations',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    _InfoRow(label: 'Position', value: 'Intern'),
                    _InfoRow(label: 'Qualification', value: 'Under-Graduate'),
                    _InfoRow(label: 'Experience', value: 'none'),
                    _InfoRow(label: 'Job Type', value: 'Hybrid'),
                    _InfoRow(label: 'Specialization', value: 'AI and Data Science'),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Facilities
                    Text(
                      'Facilities and Others',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    _BulletItem(text: 'Managing Data Sets'),
                    _BulletItem(text: 'Ability to understand'),
                    _BulletItem(text: 'Technical Catification'),
                    _BulletItem(text: 'Feedback'),
                    _BulletItem(text: 'Transport Allowance'),
                    _BulletItem(text: 'Regular Hours'),
                    _BulletItem(text: 'Mondays-Fridays'),

                    const SizedBox(height: AppDimensions.paddingXL),

                    // Apply 
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: () => context.go('/student/upload-cv'),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem({required this.text});

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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(color: AppColors.divider),
        ],
      ),
    );
  }
}