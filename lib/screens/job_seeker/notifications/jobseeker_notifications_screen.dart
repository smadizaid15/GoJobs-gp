import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/jobseeker_bottom_nav.dart';

class JobseekerNotificationsScreen extends StatelessWidget {
  const JobseekerNotificationsScreen({super.key});

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
                  children: [
                    const SizedBox(height: AppDimensions.paddingL),

                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.menu,
                                    color: AppColors.textSecondary),
                                const SizedBox(
                                    width: AppDimensions.paddingS),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search',
                                      hintStyle: AppTextStyles.bodySmall,
                                      border: InputBorder.none,
                                      filled: false,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.search,
                                    color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: AppDimensions.paddingM),

                        GestureDetector(
                          onTap: () =>
                              context.go('/jobseeker/profile'),
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

                    const SizedBox(height: AppDimensions.paddingM),

                    // Filter tabs
                    Row(
                      children: [
                        _FilterTab(label: 'All', isSelected: true),
                        const SizedBox(width: AppDimensions.paddingS),
                        _FilterTab(label: 'Jobs', isSelected: false),
                        const SizedBox(width: AppDimensions.paddingS),
                        _FilterTab(
                            label: 'Messages', isSelected: false),
                        const Spacer(),
                        Text(
                          'Filter',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    _NotificationItem(
                      title: 'Intern',
                      subtitle:
                          'new opportunity in Amman, Jordan',
                      actionLabel: 'View job',
                      onAction: () =>
                          context.push('/jobseeker/job-detail'),
                      isRead: false,
                    ),

                    _NotificationItem(
                      title: 'UI/Ux',
                      subtitle: 'new opportunity in Irbid, Jordan',
                      actionLabel: 'View job',
                      onAction: () =>
                          context.push('/jobseeker/job-detail'),
                      isRead: false,
                    ),

                    _NotificationItem(
                      title: 'Your monday jobs report',
                      subtitle:
                          '5 companies are hiring for Web developer roles this week. View more insights',
                      onAction: null,
                      isRead: true,
                    ),

                    _NotificationItem(
                      title: 'Talent management',
                      subtitle:
                          'new opportunity in Irbid, Jordan',
                      actionLabel: 'View job',
                      onAction: () =>
                          context.push('/jobseeker/job-detail'),
                      isRead: false,
                    ),

                    _NotificationItem(
                      title: 'Public relations',
                      subtitle:
                          'new opportunity in Amman, Jordan',
                      actionLabel: 'View job',
                      onAction: () =>
                          context.push('/jobseeker/job-detail'),
                      isRead: false,
                    ),

                    _NotificationItem(
                      title: 'Checkout different workshops',
                      subtitle:
                          'and interactive courses around you, press discover down below!',
                      actionLabel: 'Discover',
                      onAction: () {},
                      isRead: true,
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),
                  ],
                ),
              ),
            ),

            const JobseekerBottomNav(currentIndex: -1),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterTab({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingXS,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryNavy : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight:
              isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isRead;

  const _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.onAction,
    this.actionLabel,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRead
                  ? Colors.transparent
                  : AppColors.primaryOrange,
            ),
          ),

          const SizedBox(width: AppDimensions.paddingS),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: '$title : ',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(text: subtitle),
                    ],
                  ),
                ),

                if (actionLabel != null) ...[
                  const SizedBox(height: AppDimensions.paddingS),
                  GestureDetector(
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                      ),
                      child: Text(
                        actionLabel!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}