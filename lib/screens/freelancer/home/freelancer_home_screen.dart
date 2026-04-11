import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/freelancer_bottom_nav.dart';

class FreelancerHomeScreen extends StatelessWidget {
  const FreelancerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/ai-chat'),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(
          Icons.smart_toy_outlined,
          color: Colors.white,
        ),
      ),
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

                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Zaid Smadi.',
                              style: AppTextStyles.heading3.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingS,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusFull),
                              ),
                              child: Text(
                                'Freelance',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  context.go('/freelancer/settings'),
                              child: const Icon(
                                Icons.settings_outlined,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingS),
                            GestureDetector(
                              onTap: () =>
                                  context.go('/freelancer/profile'),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primaryNavy,
                                child: Text(
                                  'Z',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    Text(
                      'Pending jobs',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    _PendingJobCard(
                      title: 'Kitchen leaking problem',
                      location: 'Irbid, petra st.',
                      description:
                          'The kitchen is leaking and we need help fixing it!',
                      postedDate: 'Posted on 11/09/25',
                      onAccept: () {},
                      onDecline: () {},
                      onMessage: () =>
                          context.push('/freelancer/chat'),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    _PendingJobCard(
                      title: 'Bathroom leaking problem',
                      location: 'Irbid, rahbat.',
                      description:
                          'The bathroom is leaking and we need help fixing it!',
                      postedDate: 'Posted on 24/09/25',
                      onAccept: () {},
                      onDecline: () {},
                      onMessage: () =>
                          context.push('/freelancer/chat'),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    _PendingJobCard(
                      title: 'Bathroom leaking problem',
                      location: 'Irbid, rahbat.',
                      description:
                          'The bathroom is leaking and we need help fixing it!',
                      postedDate: 'Posted on 24/09/25',
                      onAccept: () {},
                      onDecline: () {},
                      onMessage: () =>
                          context.push('/freelancer/chat'),
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),
                  ],
                ),
              ),
            ),

            const FreelancerBottomNav(currentIndex: 0),
          ],
        ),
      ),
    );
  }
}

class _PendingJobCard extends StatelessWidget {
  final String title;
  final String location;
  final String description;
  final String postedDate;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onMessage;

  const _PendingJobCard({
    required this.title,
    required this.location,
    required this.description,
    required this.postedDate,
    required this.onAccept,
    required this.onDecline,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      location,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                postedDate,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingS),

          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppDimensions.paddingM),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onAccept,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryNavy),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                  child: Text(
                    'Accept',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingS),
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                  child: Text(
                    'Decline',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingS),
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