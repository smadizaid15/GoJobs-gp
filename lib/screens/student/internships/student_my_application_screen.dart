import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class StudentMyApplicationScreen extends StatelessWidget {
  const StudentMyApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.paddingL),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/student/home'),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Text(
                    'My Applications',
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Applications List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('applications')
                    .where('userId', isEqualTo: currentUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading applications.'));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'You haven\'t applied to any internships yet.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  // Sort locally to avoid needing a composite index in Firestore right away
                  docs.sort((a, b) {
                    final aTime = (a.data() as Map<String, dynamic>)['appliedAt'] as Timestamp?;
                    final bTime = (b.data() as Map<String, dynamic>)['appliedAt'] as Timestamp?;
                    if (aTime == null || bTime == null) return 0;
                    return bTime.compareTo(aTime);
                  });

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      
                      final title = data['jobTitle'] ?? 'Position';
                      final company = data['companyName'] ?? 'Company';
                      final location = data['location'] ?? 'Location';
                      final logoUrl = data['logoUrl'];
                      final status = data['status'] ?? 'Pending';
                      final appliedAt = data['appliedAt'] as Timestamp?;
                      
                      String dateStr = 'Recently';
                      if (appliedAt != null) {
                        dateStr = DateFormat('MMM dd, yyyy').format(appliedAt.toDate());
                      }

                      Color statusColor = AppColors.primaryOrange;
                      if (status.toLowerCase() == 'accepted') statusColor = Colors.green;
                      if (status.toLowerCase() == 'rejected') statusColor = AppColors.error;

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
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
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.inputFill,
                                        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                        image: logoUrl != null 
                                            ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover)
                                            : null,
                                      ),
                                      child: logoUrl == null
                                          ? const Icon(Icons.business, color: AppColors.textSecondary, size: 20)
                                          : null,
                                    ),
                                    const SizedBox(width: AppDimensions.paddingM),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          company,
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                  ),
                                  child: Text(
                                    status,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.paddingM),
                            const Divider(color: AppColors.divider),
                            const SizedBox(height: AppDimensions.paddingS),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  location,
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                                Text(
                                  'Applied: $dateStr',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}