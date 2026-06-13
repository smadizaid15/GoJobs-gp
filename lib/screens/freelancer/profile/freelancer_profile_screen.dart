import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/freelancer_bottom_nav.dart';

class FreelancerProfileScreen extends StatefulWidget {
  const FreelancerProfileScreen({super.key});

  @override
  State<FreelancerProfileScreen> createState() =>
      _FreelancerProfileScreenState();
}

class _FreelancerProfileScreenState extends State<FreelancerProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSubmitting = false;

  Future<void> _toggleAvailability(bool value) async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'isAvailable': value,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not authenticated. Please log in.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('users').doc(user.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryOrange,
                  ),
                ),
              );
            }

            final userData =
                snapshot.data?.data() as Map<String, dynamic>? ?? {};
            final String displayName = userData['name'] ?? 'Freelancer';
            final String location = userData['location'] ?? 'Irbid, Jordan';
            final bool isAvailable = userData['isAvailable'] ?? false;
            final String firstLetter = displayName.isNotEmpty
                ? displayName[0].toUpperCase()
                : 'Z';

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryNavy,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(
                                AppDimensions.radiusXL,
                              ),
                              bottomRight: Radius.circular(
                                AppDimensions.radiusXL,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => context.go('/freelancer/home'),
                                    child: const Icon(
                                      Icons.share_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        context.go('/freelancer/settings'),
                                    child: const Icon(
                                      Icons.settings_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundColor: AppColors.inputFill,
                                        child: Text(
                                          firstLetter,
                                          style: AppTextStyles.heading2
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: AppDimensions.paddingM,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  AppDimensions.paddingS,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryOrange,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppDimensions.radiusFull,
                                                  ),
                                            ),
                                            child: Text(
                                              'Freelance',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  Column(
                                    children: [
                                      Text(
                                        isAvailable ? 'Active' : 'Inactive',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: isAvailable
                                              ? Colors.greenAccent
                                              : Colors.white70,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      _isSubmitting
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : Switch.adaptive(
                                              value: isAvailable,
                                              activeColor: Colors.greenAccent,
                                              activeTrackColor: Colors
                                                  .greenAccent
                                                  .withOpacity(0.4),
                                              inactiveThumbColor:
                                                  Colors.white70,
                                              inactiveTrackColor:
                                                  Colors.white24,
                                              onChanged: _toggleAvailability,
                                            ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                              Text(
                                displayName,
                                style: AppTextStyles.heading3.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                location,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                              GestureDetector(
                                onTap: () =>
                                    context.go('/freelancer/edit-profile'),
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
                                      const SizedBox(
                                        width: AppDimensions.paddingXS,
                                      ),
                                      const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: AppDimensions.paddingS),

                              Text(
                                'You are now in the freelance page\nHere, you can post skills to be hired instantly',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white60,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppDimensions.paddingL),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingL,
                          ),
                          child: Column(
                            children: [
                              _ProfileSection(
                                icon: Icons.person_outline,
                                label: 'About me/Description',
                                onTap: () =>
                                    context.push('/freelancer/about-me'),
                              ),
                              _ProfileSection(
                                icon: Icons.handyman_outlined,
                                label: 'Services offered',
                                onTap: () =>
                                    context.push('/freelancer/services'),
                              ),
                              _ProfileSection(
                                icon: Icons.star_outline,
                                label: 'Rate, skills and tools, Availability',
                                onTap: () => context.push('/freelancer/skills'),
                              ),
                              _ProfileSection(
                                icon: Icons.photo_library_outlined,
                                label: 'Portfolio/work photos',
                                onTap: () =>
                                    context.push('/freelancer/portfolio'),
                              ),
                              const SizedBox(height: AppDimensions.paddingXL),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const FreelancerBottomNav(currentIndex: 1),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileSection({
    required this.icon,
    required this.label,
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
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryOrange),
                const SizedBox(width: AppDimensions.paddingM),
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Icon(Icons.add, color: AppColors.primaryOrange),
          ],
        ),
      ),
    );
  }
}
