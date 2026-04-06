import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../providers/auth_provider.dart';

class CompanySignupScreen extends StatefulWidget {
  const CompanySignupScreen({super.key});

  @override
  State<CompanySignupScreen> createState() => _CompanySignupScreenState();
}

class _CompanySignupScreenState extends State<CompanySignupScreen> {
  final _companyNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _licenseController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _companyNameController.dispose();
    _categoryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_companyNameController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _licenseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUpCompany(
      companyName: _companyNameController.text.trim(),
      category: _categoryController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      licenseNumber: _licenseController.text.trim(),
    );

    if (success && mounted) {
      context.go('/company/otp');
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
                'Create a Company Account',
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingS),

              Text(
                'Set up your company account to start posting jobs',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              Text('Company/Enterprise name', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _companyNameController,
                decoration: const InputDecoration(hintText: 'Calma Space'),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              Text('Company/Enterprise category', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(hintText: 'Coffee house'),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              Text('Company Email', style: AppTextStyles.labelText),
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

              Text('License/permit number', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _licenseController,
                decoration: const InputDecoration(
                  hintText: '••••••••••',
                ),
                obscureText: true,
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.companyGold,
                  ),
                  child: authProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('SIGN UP', style: AppTextStyles.buttonText),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              Center(
                child: GestureDetector(
                  onTap: () => context.go('/company/login'),
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
                            color: AppColors.companyGold,
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