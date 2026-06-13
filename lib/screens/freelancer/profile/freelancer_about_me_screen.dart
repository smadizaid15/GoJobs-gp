import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class FreelancerAboutMeScreen extends StatefulWidget {
  const FreelancerAboutMeScreen({super.key});

  @override
  State<FreelancerAboutMeScreen> createState() =>
      _FreelancerAboutMeScreenState();
}

class _FreelancerAboutMeScreenState extends State<FreelancerAboutMeScreen> {
  final _aboutController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          setState(() {
            _aboutController.text = doc.data()!['aboutMe']?.toString() ?? '';
          });
        }
      } catch (e) {
        debugPrint("Error loading About Me: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'aboutMe': _aboutController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Description updated!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/freelancer/profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
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
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimensions.paddingL),

                    GestureDetector(
                      onTap: () => context.go('/freelancer/profile'),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    Text(
                      'About me',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),

                    Container(
                      width: double.infinity,
                      height: 200,
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                      child: TextField(
                        controller: _aboutController,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText:
                              'Tell potential clients about your skills and experience.',
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveData,
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
