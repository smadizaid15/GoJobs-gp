import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class CompanyEditProfileScreen extends StatefulWidget {
  const CompanyEditProfileScreen({super.key});

  @override
  State<CompanyEditProfileScreen> createState() =>
      _CompanyEditProfileScreenState();
}

class _CompanyEditProfileScreenState extends State<CompanyEditProfileScreen> {
  final _nameController =
      TextEditingController(text: 'Calma Space');
  final _categoryController =
      TextEditingController(text: 'Coffee house');
  final _emailController =
      TextEditingController(text: 'zsmadi5522@gmail.com');
  final _passwordController = TextEditingController(text: '••••••••••');
  final _licenseController = TextEditingController(text: '••••••••••');

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _licenseController.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.paddingL),

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
                    'Edit Profile',
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              Text('Company/enterprise name', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(controller: _nameController),

              const SizedBox(height: AppDimensions.paddingM),

              Text('Company/enterprise category', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(controller: _categoryController),

              const SizedBox(height: AppDimensions.paddingM),

              Text('Company Email', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(controller: _emailController),

              const SizedBox(height: AppDimensions.paddingM),

              Text('Password', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _passwordController,
                obscureText: true,
              ),

              const SizedBox(height: AppDimensions.paddingM),

              Text('License/permit number', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _licenseController,
                obscureText: true,
              ),

              const SizedBox(height: AppDimensions.paddingXL),

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
}
