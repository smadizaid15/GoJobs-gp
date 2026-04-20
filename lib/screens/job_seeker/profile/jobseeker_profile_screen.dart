import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/jobseeker_bottom_nav.dart';

class JobseekerProfileScreen extends StatelessWidget {
  const JobseekerProfileScreen({super.key});

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
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.only(
                          bottomLeft:
                              Radius.circular(AppDimensions.radiusXL),
                          bottomRight:
                              Radius.circular(AppDimensions.radiusXL),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top icons
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    context.go('/jobseeker/home'),
                                child: const Icon(
                                  Icons.share_outlined,
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    context.go('/jobseeker/settings'),
                                child: const Icon(
                                  Icons.settings_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          // Profile pic
                          CircleAvatar(
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

                          const SizedBox(height: AppDimensions.paddingM),

                          Text(
                            'Zaid Smadi.',
                            style: AppTextStyles.heading3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            'Irbid, Jordan',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          // Edit profile 
                          GestureDetector(
                           onTap: () => context.push('/jobseeker/edit-profile'),
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
                                border:
                                    Border.all(color: Colors.white54),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Edit profile',
                                    style: AppTextStyles.bodySmall
                                        .copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(
                                      width: AppDimensions.paddingXS),
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

                    // Profile section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      child: Column(
                        children: [
                          _ProfileSection(
                            icon: Icons.person_outline,
                            label: 'About me',
                            onTap: () => context
                                .push('/jobseeker/about-me'),
                          ),
                          _ProfileSection(
                            icon: Icons.work_outline,
                            label: 'Work experience',
                            onTap: () => context
                                .push('/jobseeker/work-experience'),
                          ),
                          _ProfileSection(
                            icon: Icons.school_outlined,
                            label: 'Education',
                            onTap: () => context
                                .push('/jobseeker/education'),
                          ),
                          _ProfileSection(
                            icon: Icons.star_outline,
                            label: 'Skill',
                            onTap: () =>
                                context.push('/jobseeker/skills'),
                          ),
                          _ProfileSection(
                            icon: Icons.language_outlined,
                            label: 'Language',
                            onTap: () =>
                                context.push('/jobseeker/language'),
                          ),
                          _ProfileSection(
                            icon: Icons.description_outlined,
                            label: 'Resume',
                            onTap: () =>
                                context.push('/jobseeker/resume'),
                          ),
                          const SizedBox(
                              height: AppDimensions.paddingXL),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const JobseekerBottomNav(currentIndex: 1),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileSection({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryOrange),
                const SizedBox(width: AppDimensions.paddingM),
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.add,
              color: AppColors.primaryOrange,
            ),
          ],
        ),
      ),
    );
  }
}