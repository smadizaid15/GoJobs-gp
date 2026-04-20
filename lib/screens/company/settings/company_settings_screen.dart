import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/auth_provider.dart';

class CompanySettingsScreen extends StatelessWidget {
  const CompanySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Padding(
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
                    onTap: () => context.go('/company/profile'),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Text(
                    'Settings',
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: Column(
                  children: [
                    _SettingsToggle(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      value: true,
                      onChanged: (val) {},
                    ),

                    const Divider(height: 1, color: AppColors.divider),

                    _SettingsToggle(
                      icon: Icons.dark_mode_outlined,
                      label: 'Dark mode',
                      value: themeProvider.isDarkMode,
                      onChanged: (val) => themeProvider.toggleTheme(val),
                    ),

                    const Divider(height: 1, color: AppColors.divider),

                    _SettingsItem(
                      icon: Icons.lock_outline,
                      label: 'Password',
                      onTap: () =>
                          context.go('/company/update-password'),
                    ),

                    const Divider(height: 1, color: AppColors.divider),

                    _SettingsItem(
                      icon: Icons.logout,
                      label: 'Logout',
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => context.go('/company/profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.companyGold,
                  ),
                  child: Text('SAVE', style: AppTextStyles.buttonText),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              Text(
                'Log out',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                'Are you sure you want to leave?',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () async {
                   final authProvider = Provider.of<AuthProvider>(context, listen: false);
                   await authProvider.logout();
                   if (context.mounted) context.go('/welcome');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.companyGold,
                  ),
                  child: Text('YES', style: AppTextStyles.buttonText),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: AppColors.purpleButtonBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    backgroundColor: AppColors.purpleButton,
                  ),
                  child: Text(
                    'CANCEL',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textSecondary),
              const SizedBox(width: AppDimensions.paddingM),
              Text(label, style: AppTextStyles.bodyMedium),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.companyGold,
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingM,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.textSecondary),
                const SizedBox(width: AppDimensions.paddingM),
                Text(label, style: AppTextStyles.bodyMedium),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}