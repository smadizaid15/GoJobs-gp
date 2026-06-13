import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/company_bottom_nav.dart';

class CompanyHomeScreen extends StatefulWidget {
  const CompanyHomeScreen({super.key});

  @override
  State<CompanyHomeScreen> createState() => _CompanyHomeScreenState();
}

class _CompanyHomeScreenState extends State<CompanyHomeScreen> {
  bool isLoading = true;
  int activeJobsCount = 0;
  int totalJobsCount = 0;
  int applicantsCount = 0;
  int deletedJobsCount = 0;

  @override
  void initState() {
    super.initState();
    fetchDashboardStats();
  }

  Future<void> fetchDashboardStats() async {
    try {
      final String? currentCompanyId = FirebaseAuth.instance.currentUser?.uid;

      if (currentCompanyId == null) {
        print('No company is logged in!');
        setState(() => isLoading = false);
        return;
      }

      final url = Uri.parse('http://10.0.2.2:3000/api/companies/$currentCompanyId/dashboard-stats');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          activeJobsCount = data['activeJobs'] ?? 0;
          totalJobsCount = data['totalJobs'] ?? 0;
          applicantsCount = data['applicants'] ?? 0;
          deletedJobsCount = data['deletedJobs'] ?? 0;
          isLoading = false; 
        });
      } else {
        print('Failed to load stats');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.companyGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          border: Border.all(
                            color: AppColors.companyGold.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          'Company Dashboard',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.companyGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.go('/company/notifications'),
                            child: const Icon(Icons.notifications_outlined, color: Colors.white),
                          ),
                          const SizedBox(width: AppDimensions.paddingM),
                          GestureDetector(
                            onTap: () => context.push('/ai-chat'),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                              ),
                              child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 18),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingS),
                          
                          GestureDetector(
                            onTap: () => context.go('/company/profile'),
                            child: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
                              builder: (context, snapshot) {
                                String? logoUrl;
                                if (snapshot.hasData && snapshot.data!.exists) {
                                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                                  logoUrl = data?['logoUrl']?.toString();
                                }

                                return Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                    child: logoUrl != null && logoUrl.isNotEmpty
                                        ? Image.network(
                                            logoUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.business, color: AppColors.textSecondary),
                                          )
                                        : const Icon(Icons.business, color: AppColors.textSecondary),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find your local talent here !',
                            style: AppTextStyles.heading2.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              hintStyle: AppTextStyles.bodySmall,
                              border: InputBorder.none,
                              filled: false,
                            ),
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.companyGold,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                          ),
                          child: const Icon(Icons.search, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppDimensions.paddingL),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Specialization',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/company/jobs'),
                                child: Text(
                                  'View all',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.companyGold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.paddingM),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.work_outline,
                                  label: 'Active jobs',
                                  value: '$activeJobsCount jobs', 
                                  onTap: () => context.go('/company/jobs'),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingM),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.post_add_outlined,
                                  label: 'Jobs posted',
                                  value: '$totalJobsCount jobs', 
                                  onTap: () => context.go('/company/jobs'),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingM),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.people_outline,
                                  label: 'Applicants',
                                  value: '$applicantsCount', 
                                  onTap: () => context.go('/company/applicants'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.paddingM),
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.delete_outline,
                                  label: 'Deleted jobs',
                                  value: '$deletedJobsCount jobs', 
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingM),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => context.push('/company/add-job'),
                                  child: Container(
                                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [AppColors.primaryNavy, Color(0xFF1a1850)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.add_circle_outline,
                                          color: AppColors.companyGold,
                                          size: 32,
                                        ),
                                        const SizedBox(height: AppDimensions.paddingXS),
                                        Text(
                                          'Add new\njob',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingM),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.paddingXL),
                        ],
                      ),
                    ),
            ),
            const CompanyBottomNav(currentIndex: 0),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.companyGold),
            const SizedBox(height: AppDimensions.paddingXS),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}