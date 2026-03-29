import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';

class StudentBottomNav extends StatelessWidget {
  final int currentIndex;
  const StudentBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.bottomNavHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          GestureDetector(
            onTap: () => context.go('/student/home'),
            child: Icon(
              Icons.home_outlined,
              color: currentIndex == 0
                  ? AppColors.primaryNavy
                  : AppColors.textSecondary,
            ),
          ),

          // Notifications
          GestureDetector(
            onTap: () => context.go('/student/notifications'),
            child: Icon(
              Icons.notifications_outlined,
              color: currentIndex == 1
                  ? AppColors.primaryNavy
                  : AppColors.textSecondary,
            ),
          ),

          // + button (Courses/Workshops)
          GestureDetector(
            onTap: () => context.go('/student/courses'),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: AppColors.primaryNavy,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),

          // Chat
          GestureDetector(
            onTap: () => context.go('/student/messages'),
            child: Icon(
              Icons.chat_bubble_outline,
              color: currentIndex == 3
                  ? AppColors.primaryNavy
                  : AppColors.textSecondary,
            ),
          ),

          // Saved
          GestureDetector(
            onTap: () => context.go('/student/saved'),
            child: Icon(
              Icons.bookmark_border,
              color: currentIndex == 4
                  ? AppColors.primaryNavy
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}