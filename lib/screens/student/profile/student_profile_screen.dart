import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/student_bottom_nav.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading profile.'));
            }

            final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

            final fullName = data['fullName']?.toString() ?? data['displayName']?.toString() ?? 'Student';
            final location = data['location']?.toString() ?? 'Location not set';
            final university = data['university']?.toString() ?? 'University not set';
            final dob = data['dob']?.toString() ?? 'Not set';
            final gender = data['gender']?.toString() ?? 'Not set';
            final email = data['email']?.toString() ?? user.email ?? 'Not set';
            final phone = data['phone']?.toString() ?? 'Not set';
            final major = data['major']?.toString() ?? 'Major not set';
            final profileImageUrl = data['profileImageUrl']?.toString();

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryNavy,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(AppDimensions.radiusXL),
                              bottomRight: Radius.circular(AppDimensions.radiusXL),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top icons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => context.go('/student/home'),
                                    child: const Icon(
                                      Icons.share_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.go('/student/settings'),
                                    child: const Icon(
                                      Icons.settings_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                              // Profile pic
                              Align(
                                alignment: Alignment.centerLeft,
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppColors.inputFill,
                                  backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                                      ? NetworkImage(profileImageUrl)
                                      : null,
                                  child: profileImageUrl == null || profileImageUrl.isEmpty
                                      ? Text(
                                          fullName.isNotEmpty ? fullName[0].toUpperCase() : 'S',
                                          style: AppTextStyles.heading2.copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                              Text(
                                '$fullName.',
                                style: AppTextStyles.heading3.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),

                              Text(
                                location,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.left,
                              ),

                              Text(
                                university,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.left,
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                              // Edit profile 
                              GestureDetector(
                                onTap: () => context.go('/student/edit-profile'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.paddingL,
                                    vertical: AppDimensions.paddingXS,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusFull,
                                    ),
                                    border: Border.all(color: Colors.white54),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Edit profile',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: AppDimensions.paddingXS),
                                      const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppDimensions.paddingL),

                        // Profile info 
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingL,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Back button
                              GestureDetector(
                                onTap: () => context.go('/student/home'),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: AppColors.textPrimary,
                                ),
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                              Text('Fullname', style: AppTextStyles.labelText),
                              const SizedBox(height: AppDimensions.paddingXS),
                              _ProfileField(value: fullName),

                              const SizedBox(height: AppDimensions.paddingM),

                              Text('Date of birth', style: AppTextStyles.labelText),
                              const SizedBox(height: AppDimensions.paddingXS),
                              _ProfileField(
                                value: dob,
                                trailing: const Icon(
                                  Icons.calendar_today_outlined,
                                  color: AppColors.textSecondary,
                                  size: 18,
                                ),
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                              Text('Gender', style: AppTextStyles.labelText),
                              const SizedBox(height: AppDimensions.paddingS),
                              Row(
                                children: [
                                  _GenderOption(label: 'Male', isSelected: gender.toLowerCase() == 'male'),
                                  const SizedBox(width: AppDimensions.paddingM),
                                  _GenderOption(label: 'Female', isSelected: gender.toLowerCase() == 'female'),
                                ],
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                              Text('Email address', style: AppTextStyles.labelText),
                              const SizedBox(height: AppDimensions.paddingXS),
                              _ProfileField(value: email),

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
                                          AppDimensions.radiusM),
                                    ),
                                    child: Row(
                                      children: [
                                        Text('962+', style: AppTextStyles.bodySmall),
                                        const Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.paddingS),
                                  Expanded(
                                    child: _ProfileField(value: phone),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                              Text('University', style: AppTextStyles.labelText),
                              const SizedBox(height: AppDimensions.paddingXS),
                              _ProfileField(value: university),

                              const SizedBox(height: AppDimensions.paddingM),

                              Text('Major', style: AppTextStyles.labelText),
                              const SizedBox(height: AppDimensions.paddingXS),
                              _ProfileField(value: major),

                              const SizedBox(height: AppDimensions.paddingXL),

                              // Done Button
                              SizedBox(
                                width: double.infinity,
                                height: AppDimensions.buttonHeight,
                                child: ElevatedButton(
                                  onPressed: () => context.go('/student/home'),
                                  child: Text(
                                    'DONE',
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

                const StudentBottomNav(currentIndex: -1),
              ],
            );
          }
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String value;
  final Widget? trailing;

  const _ProfileField({required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingM,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Expanded wrapper strictly kills the RenderFlex overflow error
          Expanded(
            child: Text(
              value, 
              style: AppTextStyles.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!
          ],
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _GenderOption({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}