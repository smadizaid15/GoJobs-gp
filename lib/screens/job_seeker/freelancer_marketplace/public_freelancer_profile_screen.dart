import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class PublicFreelancerProfileScreen extends StatelessWidget {
  final Map<String, dynamic> providerData;

  const PublicFreelancerProfileScreen({super.key, required this.providerData});

  @override
  Widget build(BuildContext context) {
    final name = providerData['fullName']?.toString() ?? providerData['displayName']?.toString() ?? providerData['name']?.toString() ?? 'Freelancer';
    final profession = providerData['category']?.toString() ?? providerData['profession']?.toString() ?? 'Service Provider';
    final about = providerData['aboutMe']?.toString() ?? providerData['description']?.toString() ?? 'No description provided.';
    final profileImageUrl = providerData['freelancerAvatarUrl']?.toString() ??
                            providerData['profileImageUrl']?.toString(); 
                         

    final List<String> skills = [];
    if (providerData['skills'] != null) {
      skills.addAll(List<String>.from(providerData['skills']));
    }
    if (skills.isEmpty) skills.add('General Services');

    final List<String> portfolioPhotos = [];
    if (providerData['portfolioPhotos'] != null) {
      portfolioPhotos.addAll(List<String>.from(providerData['portfolioPhotos']));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Provider Profile', style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.inputFill,
                backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
                child: profileImageUrl == null || profileImageUrl.isEmpty ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'F', style: AppTextStyles.heading1.copyWith(color: AppColors.textSecondary)) : null,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Center(child: Text(name, style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold))),
            Center(child: Text(profession, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary))),
            const SizedBox(height: AppDimensions.paddingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text('4.8 (12 reviews)', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Text('About', style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.paddingS),
            Text(about, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppDimensions.paddingL),
            Text('Skills', style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.paddingS),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) => Chip(label: Text(skill, style: AppTextStyles.bodySmall), backgroundColor: AppColors.primaryOrange.withOpacity(0.1), side: BorderSide.none)).toList(),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Text('Portfolio', style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.paddingS),
            if (portfolioPhotos.isEmpty)
              Text('No photos uploaded yet.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary))
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: portfolioPhotos.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: NetworkImage(portfolioPhotos[index]), fit: BoxFit.cover)),
                    );
                  },
                ),
              ),
            const SizedBox(height: AppDimensions.paddingXL),
          ],
        ),
      ),
    );
  }
}