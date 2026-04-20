import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/company_bottom_nav.dart';
import '../../../services/application_service.dart';
import '../../../models/application_model.dart';

class CompanyApplicantsScreen extends StatelessWidget {
  const CompanyApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  // Top row
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
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusS),
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusS),
                            child: Image.asset(
                              'assets/images/company_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.paddingL),

                  // Company name
                  Text(
                    'Calma Space',
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    'Irbid, Jordan',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // Edit profile
                  GestureDetector(
                    onTap: () => context.go('/company/edit-profile'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                        vertical: AppDimensions.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
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

            // Job filter tab
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
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusS),
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
                    'Barista',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.companyGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Filter jobs',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingM),

           // Applicant grid
            Expanded(
             child: StreamBuilder<List<ApplicationModel>>(
             stream: ApplicationService().getJobApplications('all'),
             builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
                  }

                    final applications = snapshot.data ?? [];

                     if (applications.isEmpty) {
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

      return GridView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppDimensions.paddingS,
          mainAxisSpacing: AppDimensions.paddingS,
          childAspectRatio: 0.85,
        ),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final app = applications[index];
          return _ApplicantCard(
            name: app.userName,
            description: 'Applied for ${app.jobTitle}',
            onViewProfile: () {},
            onAccept: () async {
              await ApplicationService().updateApplicationStatus(
                applicationId: app.id,
                status: 'accepted',
              );
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
              await ApplicationService().updateApplicationStatus(
                applicationId: app.id,
                status: 'rejected',
              );
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
    },
  ),
),

            const SizedBox(height: AppDimensions.paddingM),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
              ),
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  'view more applicants.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.paddingM),

            const CompanyBottomNav(currentIndex: 4),
          ],
        ),
      ),
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
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: const Center(
                      child: Text(
                        'Accept',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
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
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: const Center(
                      child: Text(
                        'Reject',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
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