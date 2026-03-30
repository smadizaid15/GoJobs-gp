import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';

class CompanyBottomNav extends StatelessWidget {
  final int currentIndex;
  const CompanyBottomNav({super.key, required this.currentIndex});

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
            onTap: () => context.go('/company/home'),
            child: Icon(
              Icons.home_outlined,
              color: currentIndex == 0
                  ? AppColors.primaryNavy
                  : AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/company/profile'),
            child: Icon(
              Icons.person_outline,
              color: currentIndex == 1
                  ? AppColors.primaryNavy
                  : AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/company/add-job'),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: AppColors.companyGold,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/company/messages'),
            child: Icon(
              Icons.chat_bubble_outline,
              color: currentIndex == 3
                  ? AppColors.primaryNavy
                  : AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/company/applicants'),
            child: Icon(
              Icons.people_outline,
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