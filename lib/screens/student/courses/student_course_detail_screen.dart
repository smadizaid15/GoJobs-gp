import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class StudentCourseDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? courseData; // Accept data from the router

  const StudentCourseDetailScreen({super.key, this.courseData});

  @override
  State<StudentCourseDetailScreen> createState() => _StudentCourseDetailScreenState();
}

class _StudentCourseDetailScreenState extends State<StudentCourseDetailScreen> {
  bool _isEnrolling = false;

  Future<void> _enrollInCourse() async {
    final user = FirebaseAuth.instance.currentUser;
    final courseId = widget.courseData?['id'];
    
    if (user == null || courseId == null) return;

    setState(() => _isEnrolling = true);

    try {
      // Create an enrollment record in Firestore
      await FirebaseFirestore.instance.collection('course_enrollments').add({
        'studentId': user.uid,
        'courseId': courseId,
        'courseTitle': widget.courseData?['title'] ?? 'Unknown Course',
        'enrolledAt': FieldValue.serverTimestamp(),
        'status': 'enrolled',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully enrolled!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to enroll: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isEnrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely extract all dynamic data
    final data = widget.courseData ?? {};
    final title = data['title']?.toString() ?? 'Course Details';
    final company = data['companyName']?.toString() ?? 'Institution';
    final isOnline = data['isOnline'] as bool? ?? false;
    final location = isOnline ? 'Online' : (data['location']?.toString() ?? 'On-site');
    final isFree = data['isFree'] as bool? ?? false;
    final priceStr = isFree ? 'Free of charge' : (data['price']?.toString() ?? 'Paid');
    final description = data['description']?.toString() ?? 'No description provided.';
    final logoUrl = data['logoUrl']?.toString();
    final List<String> learningPoints = List<String>.from(data['learningPoints'] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.paddingL),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                child: GestureDetector(
                  onTap: () => context.pop(), // Returns safely without hardcoding route
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Company logo and name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                          image: logoUrl != null 
                              ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover)
                              : null,
                        ),
                        child: logoUrl == null
                            ? const Icon(Icons.business, color: AppColors.textSecondary, size: 40)
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Center(
                      child: Text(
                        company,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Course title and Meta
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        title,
                        style: AppTextStyles.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(location, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          const Text(' • '),
                          Text(isOnline ? 'Online' : 'On site', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          const Text(' • '),
                          Text(priceStr, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    Center(
                      child: OutlinedButton(
                        onPressed: () {
                          // Could push to an institution profile screen if you have one
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.purpleButtonBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          backgroundColor: AppColors.purpleButton,
                        ),
                        child: Text(
                          'View enterprise',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    Text(
                      'Course Description',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingS),

                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    if (learningPoints.isNotEmpty) ...[
                      Text(
                        'What You Will Learn:',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingS),
                      ...learningPoints.map((point) => _LearnItem(text: point)).toList(),
                      const SizedBox(height: AppDimensions.paddingXL),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isEnrolling ? null : _enrollInCourse,
                        child: _isEnrolling
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'ENROLL NOW',
                                style: AppTextStyles.buttonText,
                              ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearnItem extends StatelessWidget {
  final String text;
  const _LearnItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.textPrimary)),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}