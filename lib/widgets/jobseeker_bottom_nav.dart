import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';

class JobseekerBottomNav extends StatelessWidget {
  final int currentIndex;
  const JobseekerBottomNav({super.key, required this.currentIndex});

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
          GestureDetector(
            onTap: () => context.go('/jobseeker/home'),
            child: Icon(
              Icons.home_outlined,
              color: currentIndex == 0
                  ? AppColors.primaryNavy
                  : AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/jobseeker/profile'),
            child: Icon(
              Icons.people_outline,
              color: currentIndex == 1
                  ? AppColors.primaryNavy
                  : AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/jobseeker/search'),
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
          GestureDetector(
            onTap: () => context.go('/jobseeker/messages'),
            child: Icon(
              Icons.chat_bubble_outline,
              color: currentIndex == 3
                  ? AppColors.primaryNavy
                  : AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/jobseeker/saved'),
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