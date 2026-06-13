import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class StudentInternshipDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? jobData;

  const StudentInternshipDetailScreen({super.key, this.jobData});

  @override
  Widget build(BuildContext context) {
    // Safely extract data
    final data = jobData ?? {};
    final title = data['title']?.toString() ?? 'Internship';
    final company = data['companyName']?.toString() ?? 'Company';
    final location = data['location']?.toString() ?? 'Location';
    final type = data['workplaceType']?.toString() ?? 'On-site';
    final duration = data['duration']?.toString() ?? 'Duration unlisted';
    final description = data['description']?.toString() ?? 'No description available.';
    final requirements = List<String>.from(data['requirements'] ?? []);
    final qualifications = data['qualifications']?.toString() ?? 'None listed';
    final experienceLevel = data['experienceLevel']?.toString() ?? 'Entry Level';
    final logoUrl = data['logoUrl']?.toString();

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
                  onTap: () => context.pop(),
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
                        image: logoUrl != null 
                            ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover)
                            : null,
                      ),
                      child: logoUrl == null 
                          ? const Icon(Icons.business, color: AppColors.textSecondary, size: 40)
                          : null,
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Text(
                      company,
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
                        title,
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
                            location,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Text(' • '),
                          Text(
                            type,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Text(' • '),
                          Text(
                            duration,
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
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    if (requirements.isNotEmpty) ...[
                      Text(
                        'What you will do:',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingS),
                      ...requirements.map((req) => _BulletItem(text: req)).toList(),
                      const SizedBox(height: AppDimensions.paddingL),
                    ],

                    // Location Map Placeholder
                    Text(
                      'Location',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    Text(
                      location,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

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
                    _InfoRow(label: 'Qualification', value: qualifications),
                    _InfoRow(label: 'Experience', value: experienceLevel),
                    _InfoRow(label: 'Job Type', value: type),

                    const SizedBox(height: AppDimensions.paddingXL),

                    // Apply - Pass the dynamic job info to the CV upload screen
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: () => context.push('/student/upload-cv', extra: data),
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