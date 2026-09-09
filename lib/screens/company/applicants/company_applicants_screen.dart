import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/company_bottom_nav.dart';


class CompanyApplicantsScreen extends StatelessWidget {
  const CompanyApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. 🛡️ AUTH SAFETY NET
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF0F0F5),
            body: Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
          );
        }

        final currentUserId = authSnapshot.data?.uid ?? '';

        if (currentUserId.isEmpty) {
          return const Scaffold(
            backgroundColor: Color(0xFFF0F0F5),
            body: Center(child: Text('Loading authentication...')),
          );
        }

        // 2. 🛡️ LIVE COMPANY PROFILE STREAM (Replaces initState)
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
          builder: (context, userSnapshot) {
            String companyName = 'Your Company';
            String companyLocation = 'Location not set';
            String? companyLogoUrl;

            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              final userData = userSnapshot.data!.data() as Map<String, dynamic>;
              companyName = userData['companyName']?.toString() ?? 'Your Company';
              companyLocation = userData['location']?.toString() ?? 'Location not set';
              companyLogoUrl = userData['logoUrl']?.toString();
            }

            return Scaffold(
              backgroundColor: const Color(0xFFF0F0F5),
              body: SafeArea(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryNavy, Color(0xFF1a1850)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(AppDimensions.radiusXL),
                          bottomRight: Radius.circular(AppDimensions.radiusXL),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => context.go('/company/profile'),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusS,
                                    ),
                                    image: companyLogoUrl != null && companyLogoUrl.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(companyLogoUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: companyLogoUrl == null || companyLogoUrl.isEmpty
                                      ? const Icon(
                                          Icons.business,
                                          color: AppColors.primaryNavy,
                                        )
                                      : null,
                                ),
                              ),
                              const Icon(Icons.more_vert, color: Colors.white),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.paddingL),

                          Text(
                            companyName,
                            style: AppTextStyles.heading2.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            companyLocation,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          GestureDetector(
                            onTap: () => context.go('/company/edit-profile'),
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

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                              vertical: AppDimensions.paddingXS,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.companyGold,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusS,
                              ),
                            ),
                            child: Text(
                              'Job applicants',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingM),
                          Text(
                            'All Jobs',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.companyGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    // 3. 🛡️ THE APPLICANT QUERY
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('applications')
                            .where('companyId', isEqualTo: currentUserId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            print('🚨 FIREBASE ERROR: ${snapshot.error}');
                            return Center(
                              child: Text('Error loading applications: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                            );
                          }

                          final docs = snapshot.data?.docs ?? [];

                          if (docs.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.people_outline,
                                    color: AppColors.textSecondary,
                                    size: 60,
                                  ),
                                  const SizedBox(height: AppDimensions.paddingM),
                                  Text(
                                    'No applicants yet',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final sortedDocs = docs.toList();
                          sortedDocs.sort((a, b) {
                            final aTime = (a.data() as Map)['appliedAt'] as Timestamp?;
                            final bTime = (b.data() as Map)['appliedAt'] as Timestamp?;
                            if (aTime == null || bTime == null) return 0;
                            return bTime.compareTo(aTime);
                          });

                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingL,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: AppDimensions.paddingS,
                              mainAxisSpacing: AppDimensions.paddingS,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: sortedDocs.length,
                            itemBuilder: (context, index) {
                              return _LiveApplicantCard(
                                applicationDoc: sortedDocs[index],
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),
                    const CompanyBottomNav(currentIndex: 4),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _LiveApplicantCard extends StatelessWidget {
  final QueryDocumentSnapshot applicationDoc;

  const _LiveApplicantCard({required this.applicationDoc});

  @override
  Widget build(BuildContext context) {
    final data = applicationDoc.data() as Map<String, dynamic>;
    final applicantId = data['userId']?.toString() ?? '';
    final jobId = data['jobId']?.toString() ?? '';

    // 4. 🛡️ CRASH PREVENTION: Do not search Firebase if the ID is missing
    if (applicantId.isEmpty || jobId.isEmpty) {
      return const SizedBox.shrink(); 
    }

    return FutureBuilder(
      future: Future.wait([
        FirebaseFirestore.instance.collection('users').doc(applicantId).get(),
        FirebaseFirestore.instance.collection('jobs').doc(jobId).get(),
      ]),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          );
        }

        final userDoc = snapshot.data![0];
        final jobDoc = snapshot.data![1];

        String userName = 'Unknown User';
        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data() as Map<String, dynamic>;
          userName = userData['displayName'] ?? userData['fullName'] ?? 'Applicant';
        }

        String jobTitle = 'Deleted Job';
        if (jobDoc.exists && jobDoc.data() != null) {
          jobTitle = (jobDoc.data() as Map<String, dynamic>)['title'] ?? 'Unknown Job';
        }

        final fullApplicationData = {
          'id': applicationDoc.id,
          ...data,
          'userName': userName,
          'jobTitle': jobTitle,
        };

        return _ApplicantCard(
          name: userName,
          description: 'Applied for $jobTitle',
          onViewProfile: () => context.push(
            '/company/applicant-detail',
            extra: fullApplicationData,
          ),
          onAccept: () async {
            await FirebaseFirestore.instance
                .collection('applications')
                .doc(applicationDoc.id)
                .update({'status': 'accepted'});
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Applicant accepted!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          onReject: () async {
            await FirebaseFirestore.instance
                .collection('applications')
                .doc(applicationDoc.id)
                .update({'status': 'rejected'});
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Applicant rejected'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        );
      },
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final String name;
  final String description;
  final VoidCallback onViewProfile;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ApplicantCard({
    required this.name,
    required this.description,
    required this.onViewProfile,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingS),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          Expanded(
            child: Text(
              description,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white70,
                fontSize: 8,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onViewProfile,
                  child: Text(
                    'view profile',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                      fontSize: 8,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onAccept,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusS,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Accept',
                        style: TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: GestureDetector(
                  onTap: onReject,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusS,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Reject',
                        style: TextStyle(color: Colors.white, fontSize: 8),
                      ),
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

