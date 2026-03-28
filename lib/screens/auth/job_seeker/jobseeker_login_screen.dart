import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class JobseekerLoginScreen extends StatefulWidget {
  const JobseekerLoginScreen({super.key});

  @override
  State<JobseekerLoginScreen> createState() => _JobseekerLoginScreenState();
}

class _JobseekerLoginScreenState extends State<JobseekerLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Title
              Text(
                'Welcome Back',
                style: AppTextStyles.heading1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.paddingS),

              // Subtitle
              Text(
                'Please enter your credentials so you can log in and get right back to job hunting!',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Email
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Email', style: AppTextStyles.labelText),
              ),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'smadizaid1000@gmail.com',
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Password
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Password', style: AppTextStyles.labelText),
              ),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••••',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Remember me + Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: AppColors.primaryNavy,
                        onChanged: (val) {
                          setState(() {
                            _rememberMe = val ?? false;
                          });
                        },
                      ),
                      Text(
                        'Remember me',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.go('/jobseeker/forgot-password'),
                    child: Text(
                      'Forgot Password ?',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Login button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => context.go('/jobseeker/home'),
                  child: Text(
                    'LOGIN',
                    style: AppTextStyles.buttonText,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Sign in with Google
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    backgroundColor: const Color(0xFFF0EEFF),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Colorful Google G
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(text: 'G', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20)),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingS),
                      Text(
                        'SIGN IN WITH GOOGLE',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Don't have an account
              GestureDetector(
                onTap: () => context.go('/jobseeker/signup'),
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: "You don't have an account yet? "),
                      TextSpan(
                        text: 'Sign up',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              
              
              // Not your role
              const SizedBox(height: 60),

// Not your role
GestureDetector(
  onTap: () => context.go('/welcome'),
  child: Column(
    children: [
      Text(
        'Not your role ?',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      Text(
        'Press here to go back',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    ],
  ),
),

const SizedBox(height: AppDimensions.paddingXL),

              const SizedBox(height: AppDimensions.paddingXL),
            ],
          ),
        ),
      ),
    );
  }
}