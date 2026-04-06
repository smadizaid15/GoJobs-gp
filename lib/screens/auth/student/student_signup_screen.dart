import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../providers/auth_provider.dart';

class StudentSignupScreen extends StatefulWidget {
  const StudentSignupScreen({super.key});

  @override
  State<StudentSignupScreen> createState() => _StudentSignupScreenState();
}

class _StudentSignupScreenState extends State<StudentSignupScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUpStudent(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      context.go('/student/otp');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Signup failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.paddingXL),

              Text(
                'Create a Student Account',
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingS),

              Text(
                'Set up your student account to start exploring internships and courses',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              Text('First Name', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(hintText: 'Zaid'),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              Text('Last Name', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(hintText: 'Smadi'),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              Text('Email', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'zsmadi5522@gmail.com',
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              Text('Create Password', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••••',
                  suffixIcon: GestureDetector(
                    onTap: () => setState(
                        () => _obscurePassword = !_obscurePassword),
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: AppColors.primaryNavy,
                        onChanged: (val) =>
                            setState(() => _rememberMe = val ?? false),
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
                    onTap: () =>
                        context.go('/student/forgot-password'),
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

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleSignUp,
                  child: authProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('SIGN UP', style: AppTextStyles.buttonText),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              Center(
                child: GestureDetector(
                  onTap: () => context.go('/student/login'),
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign in',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              Center(
                child: GestureDetector(
                  onTap: () => context.go('/welcome'),
                  child: Text(
                    'Not your role? Press here to go back',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
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