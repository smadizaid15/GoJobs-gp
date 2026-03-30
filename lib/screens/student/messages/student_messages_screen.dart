import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/student_bottom_nav.dart';

class StudentMessagesScreen extends StatelessWidget {
  const StudentMessagesScreen({super.key});

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

                    // Title row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Messages',
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              color: AppColors.primaryOrange,
                            ),
                            const SizedBox(width: AppDimensions.paddingM),
                            const Icon(
                              Icons.more_vert,
                              color: AppColors.textPrimary,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    // Search bar
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppDimensions.paddingS),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search message',
                                hintStyle: AppTextStyles.bodySmall,
                                border: InputBorder.none,
                                filled: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    // Message list
                    _MessageTile(
                      name: 'Ahmad medhat',
                      message: 'Oh yes, please send your CV/Res...',
                      time: '5m ago',
                      hasUnread: true,
                      onTap: () => context.push('/student/chat'),
                    ),
                    _MessageTile(
                      name: 'Mustafa mahmoud',
                      message: 'Hello sir, Good Morning',
                      time: '30m ago',
                      hasUnread: false,
                      onTap: () => context.push('/student/chat'),
                    ),
                    _MessageTile(
                      name: 'Zaid smadi',
                      message: 'Start chating right now !',
                      time: '09:30 am',
                      hasUnread: false,
                      onTap: () => context.push('/student/chat'),
                    ),
                    _MessageTile(
                      name: 'Fares masaadeh',
                      message: 'Start chating right now !',
                      time: '01:00 pm',
                      hasUnread: false,
                      onTap: () => context.push('/student/chat'),
                      isDeleted: true,
                    ),
                    _MessageTile(
                      name: 'Wael Ahmad',
                      message: 'Start chating right now !',
                      time: '08:00 pm',
                      hasUnread: false,
                      onTap: () => context.push('/student/chat'),
                    ),
                    _MessageTile(
                      name: 'Talal bataineh',
                      message: 'Start chating right now !',
                      time: 'Yesterday',
                      hasUnread: false,
                      onTap: () => context.push('/student/chat'),
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),
                  ],
                ),
              ),
            ),

            const StudentBottomNav(currentIndex: 3),
          ],
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool hasUnread;
  final bool isDeleted;
  final VoidCallback onTap;

  const _MessageTile({
    required this.name,
    required this.message,
    required this.time,
    required this.hasUnread,
    required this.onTap,
    this.isDeleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Row(
          children: [
            // Avatar
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

            // Name & message
            Expanded(
              child: Column(
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
                    message,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Time + unread + delete
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXS),
                if (hasUnread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (isDeleted)
                  const Icon(
                    Icons.delete_outline,
                    color: AppColors.primaryOrange,
                    size: 18,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
