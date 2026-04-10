import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';

class JobseekerOtpScreen extends StatefulWidget {
  const JobseekerOtpScreen({super.key});

  @override
  State<JobseekerOtpScreen> createState() => _JobseekerOtpScreenState();
}

class _JobseekerOtpScreenState extends State<JobseekerOtpScreen> {
  bool _isResending = false;
  bool _isVerifying = false;
  final AuthService _authService = AuthService();

  Future<void> _handleResendEmail() async {
    setState(() => _isResending = true);
    try {
      final user = _authService.currentUser;
      await user?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isResending = false);
    }
  }

  Future<void> _handleVerify() async {
    setState(() => _isVerifying = true);
    try {
      // Reload user to check verification status
      await _authService.currentUser?.reload();
      final user = _authService.currentUser;

      if (user?.emailVerified == true) {
        if (mounted) context.go('/jobseeker/home');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Email not verified yet. Please check your inbox!'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Group67.png',
                height: 180,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              Text(
                'Verify your Email',
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.paddingS),

              Text(
                'We sent a verification email to\n${authProvider.user?.email ?? ''}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.paddingS),

              Text(
                'Please check your inbox and click the verification link, then press the button below.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _handleVerify,
                  child: _isVerifying
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : Text(
                          'I VERIFIED MY EMAIL',
                          style: AppTextStyles.buttonText,
                        ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: OutlinedButton(
                  onPressed:
                      _isResending ? null : _handleResendEmail,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: AppColors.purpleButtonBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    backgroundColor: AppColors.purpleButton,
                  ),
                  child: _isResending
                      ? const CircularProgressIndicator()
                      : Text(
                          'RESEND EMAIL',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              GestureDetector(
                onTap: () => context.go('/jobseeker/login'),
                child: Text(
                  'Back to login',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}