import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class StudentUpdatePasswordScreen extends StatefulWidget {
  const StudentUpdatePasswordScreen({super.key});

  @override
  State<StudentUpdatePasswordScreen> createState() =>
      _StudentUpdatePasswordScreenState();
}

class _StudentUpdatePasswordScreenState
    extends State<StudentUpdatePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

              // Back button and title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/student/settings'),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Text(
                    'Update Password',
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Old pass
              Text('Old Password', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _oldPasswordController,
                obscureText: _obscureOld,
                decoration: InputDecoration(
                  hintText: '••••••••••',
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscureOld = !_obscureOld),
                    child: Icon(
                      _obscureOld
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // New pass
              Text('New Password', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  hintText: '••••••••••',
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscureNew = !_obscureNew),
                    child: Icon(
                      _obscureNew
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Confirm pass
              Text('Confirm Password', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: '••••••••••',
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    child: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Update 
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => context.go('/student/settings'),
                  child: Text('UPDATE', style: AppTextStyles.buttonText),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),
            ],
          ),
        ),
      ),
    );
  }
}