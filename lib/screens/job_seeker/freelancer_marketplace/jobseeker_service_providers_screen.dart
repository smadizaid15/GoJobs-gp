import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/jobseeker_bottom_nav.dart';

class JobseekerServiceProvidersScreen extends StatelessWidget {
  const JobseekerServiceProvidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                          onTap: () => context.go('/jobseeker/home'),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingM),
                        Text(
                          'Service Providers',
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                  
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('userType', isEqualTo: 'freelancer')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return const Center(child: Text('Error loading providers.'));
                        }

                        final providers = snapshot.data?.docs ?? [];

                        if (providers.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXL),
                            child: Center(
                              child: Text(
                                'No service providers available yet.',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: providers.length,
                          itemBuilder: (context, index) {
                            final data = providers[index].data() as Map<String, dynamic>;
                            
                            final name = data['fullName']?.toString() ?? data['displayName']?.toString() ?? 'Freelancer';
                            final profession = data['category']?.toString() ?? data['profession']?.toString() ?? 'Service Provider';
                            final description = data['aboutMe']?.toString() ?? data['description']?.toString() ?? 'Available for hire.';
                            final profileImageUrl = data['profileImageUrl']?.toString() ?? data['logoUrl']?.toString();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                              child: _ServiceProviderCard(
                                name: name,
                                profession: profession,
                                description: description,
                                imageUrl: profileImageUrl,
                                time: 'Available now', 
                                onViewProfile: () {
                                  
                                },
                                onMessage: () => context.push('/jobseeker/chat-from-providers'),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),
                  ],
                ),
              ),
            ),

            const JobseekerBottomNav(currentIndex: -1),
          ],
        ),
      ),
    );
  }
}

class _ServiceProviderCard extends StatelessWidget {
  final String name;
  final String profession;
  final String description;
  final String time;
  final String? imageUrl;
  final VoidCallback onViewProfile;
  final VoidCallback onMessage;

  const _ServiceProviderCard({
    required this.name,
    required this.profession,
    required this.description,
    required this.time,
    this.imageUrl,
    required this.onViewProfile,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              const Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingS),

          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.inputFill,
                backgroundImage: imageUrl != null && imageUrl!.isNotEmpty 
                    ? NetworkImage(imageUrl!) 
                    : null,
                child: imageUrl == null || imageUrl!.isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      profession,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingS),

          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppDimensions.paddingM),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewProfile,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryNavy),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                  child: Text(
                    'View Profile',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: ElevatedButton(
                  onPressed: onMessage,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                  child: Text(
                    'Message',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}