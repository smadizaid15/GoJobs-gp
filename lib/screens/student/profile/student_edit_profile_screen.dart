import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class StudentEditProfileScreen extends StatefulWidget {
  const StudentEditProfileScreen({super.key});

  @override
  State<StudentEditProfileScreen> createState() =>
      _StudentEditProfileScreenState();
}

class _StudentEditProfileScreenState extends State<StudentEditProfileScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _universityController = TextEditingController();
  final _majorController = TextEditingController();
  bool _isMale = true;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          setState(() {
            _nameController.text =
                data['fullName'] ?? data['displayName'] ?? '';
            _dobController.text = data['dob'] ?? '';
            _emailController.text = data['email'] ?? user.email ?? '';
            _phoneController.text = data['phone'] ?? '';
            _locationController.text = data['location'] ?? '';
            _universityController.text = data['university'] ?? '';
            _majorController.text = data['major'] ?? '';
            _isMale = data['gender'] == 'Female' ? false : true;
          });
        }
      } catch (e) {
        debugPrint("Error loading profile: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'fullName': _nameController.text.trim(),
            'dob': _dobController.text.trim(),
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(),
            'location': _locationController.text.trim(),
            'university': _universityController.text.trim(),
            'major': _majorController.text.trim(),
            'gender': _isMale ? 'Male' : 'Female',
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/student/profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimensions.paddingL),

                    GestureDetector(
                      onTap: () => context.go('/student/profile'),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    Text(
                      'Edit Profile',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),

                    Text('Fullname', style: AppTextStyles.labelText),
                    const SizedBox(height: AppDimensions.paddingXS),
                    TextField(controller: _nameController),

                    const SizedBox(height: AppDimensions.paddingM),

                    Text('Date of birth', style: AppTextStyles.labelText),
                    const SizedBox(height: AppDimensions.paddingXS),
                    TextField(
                      controller: _dobController,
                      decoration: const InputDecoration(
                        suffixIcon: Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    Text('Gender', style: AppTextStyles.labelText),
                    const SizedBox(height: AppDimensions.paddingS),
                    Row(
                      children: [
                        _GenderOption(
                          label: 'Male',
                          isSelected: _isMale,
                          onTap: () => setState(() => _isMale = true),
                        ),
                        const SizedBox(width: AppDimensions.paddingL),
                        _GenderOption(
                          label: 'Female',
                          isSelected: !_isMale,
                          onTap: () => setState(() => _isMale = false),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    Text('Email address', style: AppTextStyles.labelText),
                    const SizedBox(height: AppDimensions.paddingXS),
                    TextField(controller: _emailController),

                    const SizedBox(height: AppDimensions.paddingM),

                    Text('Phone number', style: AppTextStyles.labelText),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: AppDimensions.paddingM,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusM,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text('962+', style: AppTextStyles.bodySmall),
                              const Icon(Icons.keyboard_arrow_down, size: 16),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        Expanded(
                          child: TextField(controller: _phoneController),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    Text('Location', style: AppTextStyles.labelText),
                    const SizedBox(height: AppDimensions.paddingXS),
                    TextField(controller: _locationController),

                    const SizedBox(height: AppDimensions.paddingM),

                    Text('University', style: AppTextStyles.labelText),
                    const SizedBox(height: AppDimensions.paddingXS),
                    TextField(controller: _universityController),

                    const SizedBox(height: AppDimensions.paddingM),

                    Text('Major', style: AppTextStyles.labelText),
                    const SizedBox(height: AppDimensions.paddingXS),
                    TextField(controller: _majorController),

                    const SizedBox(height: AppDimensions.paddingXL),

                    Text(
                      'Profile Additions',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),

                    _ActionCard(
                      icon: Icons.language,
                      title: 'Add Languages',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Language route needed'),
                          ),
                        );
                      },
                    ),
                    _ActionCard(
                      icon: Icons.school_outlined,
                      title: 'Add Education',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Education route needed'),
                          ),
                        );
                      },
                    ),
                    _ActionCard(
                      icon: Icons.work_outline,
                      title: 'Add Experience (Optional)',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Experience route needed'),
                          ),
                        );
                      },
                    ),
                    _ActionCard(
                      icon: Icons.description_outlined,
                      title: 'Upload CV (Optional)',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('CV Upload manager route needed'),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),

                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfileData,
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'SAVE CHANGES',
                                style: AppTextStyles.buttonText,
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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryNavy),
                const SizedBox(width: AppDimensions.paddingM),
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
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

class _GenderOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryOrange
                    : AppColors.textSecondary,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppDimensions.paddingXS),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
