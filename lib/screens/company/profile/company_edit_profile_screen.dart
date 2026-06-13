import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: '••••••••••');
  final _licenseController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _logoUrl;
  Uint8List? _webImageBytes; 

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  
  Future<void> _loadCompanyData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['companyName']?.toString() ?? '';
          _categoryController.text = data['category']?.toString() ?? '';
          _emailController.text = data['email']?.toString() ?? '';
          _licenseController.text = data['licenseNumber']?.toString() ?? '';
          _logoUrl = data['logoUrl']?.toString();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to load profile data: $e', isError: true);
    }
  }

  Future<void> _handlePickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _webImageBytes = bytes;
      });
    }
  }

  
  Future<void> _handleSaveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Company name cannot be empty', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('No authenticated user found');

      String? updatedLogoUrl = _logoUrl;

     
      if (_webImageBytes != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('company_logos')
            .child('$uid.jpg');

        final uploadTask = storageRef.putData(
          _webImageBytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final snapshot = await uploadTask;
        updatedLogoUrl = await snapshot.ref.getDownloadURL();
      }

     
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'companyName': _nameController.text.trim(),
        'category': _categoryController.text.trim(),
        'email': _emailController.text.trim(),
        'licenseNumber': _licenseController.text.trim(),
        'logoUrl': updatedLogoUrl,
      });

      _showSnackBar('Profile saved successfully!', isError: false);
      if (mounted) {
        context.go('/company/profile');
      }
    } catch (e) {
      _showSnackBar('Failed to update profile: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF0F0F5),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.companyGold),
        ),
      );
    }

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

          
              Center(
                child: GestureDetector(
                  onTap: _isSaving ? null : _handlePickLogo,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _webImageBytes != null
                              ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                              : (_logoUrl != null && _logoUrl!.isNotEmpty)
                                  ? Image.network(
                                      _logoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.business, size: 40, color: AppColors.textSecondary),
                                    )
                                  : const Icon(Icons.add_a_photo_outlined, size: 36, color: AppColors.companyGold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.companyGold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
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
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: AppDimensions.paddingM),

              Text('Password', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(
                controller: _passwordController,
                obscureText: true,
                enabled: false,
              ),

              const SizedBox(height: AppDimensions.paddingM),

              Text('License/permit number', style: AppTextStyles.labelText),
              const SizedBox(height: AppDimensions.paddingXS),
              TextField(controller: _licenseController),

              const SizedBox(height: AppDimensions.paddingXL),

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSaveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.companyGold,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('SAVE', style: AppTextStyles.buttonText),
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

