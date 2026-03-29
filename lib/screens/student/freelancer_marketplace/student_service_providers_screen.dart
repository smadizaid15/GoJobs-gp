import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/student_bottom_nav.dart';

class StudentServiceProvidersScreen extends StatelessWidget {
  const StudentServiceProvidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                          onTap: () => context.go('/student/home'),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingM),
                        Text(
                          'Service Providers',
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Service provider cards
                    _ServiceProviderCard(
                      name: 'Fares Masaadeh',
                      profession: 'Plumber',
                      description: '24/7 available round clock plumber, bathrooms, kitchens and more!',
                      time: '25 minutes',
                      onViewProfile: () {},
                      onMessage: () => context.go('/student/chat'),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    _ServiceProviderCard(
                      name: 'Zaid Kilany',
                      profession: 'Electronics repair',
                      description: 'Repairing refrigerator, Washers, Dryers, Dishwashers, Available round Clock.',
                      time: '25 minutes',
                      onViewProfile: () {},
                      onMessage: () => context.go('/student/chat'),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    _ServiceProviderCard(
                      name: 'Zaid Smadi',
                      profession: 'Carpenter',
                      description: 'Working on doors, living rooms, full kitchen makeovers',
                      time: '25 minutes',
                      onViewProfile: () {},
                      onMessage: () => context.go('/student/chat'),
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),
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

class _ServiceProviderCard extends StatelessWidget {
  final String name;
  final String profession;
  final String description;
  final String time;
  final VoidCallback onViewProfile;
  final VoidCallback onMessage;

  const _ServiceProviderCard({
    required this.name,
    required this.profession,
    required this.description,
    required this.time,
    required this.onViewProfile,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row - time + more
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              const Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingS),

          // Avatar + name + profession
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.inputFill,
                child: Text(
                  name[0],
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    profession,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingS),

          // Description
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppDimensions.paddingM),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewProfile,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryNavy),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                  child: Text(
                    'View Profile',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: ElevatedButton(
                  onPressed: onMessage,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                  child: Text(
                    'Message',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}