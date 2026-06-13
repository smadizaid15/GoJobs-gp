import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/jobseeker_bottom_nav.dart';

class JobseekerNotificationsScreen extends StatefulWidget {
  const JobseekerNotificationsScreen({super.key});

  @override
  State<JobseekerNotificationsScreen> createState() => _JobseekerNotificationsScreenState();
}

class _JobseekerNotificationsScreenState extends State<JobseekerNotificationsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _markAsReadAndNavigate(String docId, String? route) {
    FirebaseFirestore.instance.collection('notifications').doc(docId).update({
      'isRead': true,
    });
    if (route != null && route.isNotEmpty) {
      context.push(route);
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppDimensions.paddingL),

                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.menu, color: AppColors.textSecondary),
                                const SizedBox(width: AppDimensions.paddingS),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                      });
                                    },
                                    decoration:  InputDecoration(
                                      hintText: 'Search',
                                      hintStyle: AppTextStyles.bodySmall,
                                      border: InputBorder.none,
                                      filled: false,
                                    ),
                                  ),
                                ),
                                _searchQuery.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _searchController.clear();
                                            _searchQuery = '';
                                          });
                                        },
                                        child: const Icon(Icons.clear, color: AppColors.textSecondary),
                                      )
                                    : const Icon(Icons.search, color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingM),
                        GestureDetector(
                          onTap: () => context.go('/jobseeker/profile'),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primaryNavy,
                            child: Text(
                              'Z', // Could be dynamic if pulling from authProvider
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    // Filter 
                    Row(
                      children: [
                        _buildFilterTab('All'),
                        const SizedBox(width: AppDimensions.paddingS),
                        _buildFilterTab('Jobs'),
                        const SizedBox(width: AppDimensions.paddingS),
                        _buildFilterTab('Messages'),
                        const Spacer(),
                        Text(
                          'Filter',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    // LIVE Notifications from Firestore
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('notifications')
                          .where('userId', isEqualTo: currentUserId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
                          );
                        }

                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Center(child: Text('Error: ${snapshot.error}')),
                          );
                        }

                        // Extract and sort manually to avoid needing a composite index
                        final docs = snapshot.data?.docs ?? [];
                        docs.sort((a, b) {
                          final tA = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                          final tB = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                          if (tA == null && tB == null) return 0;
                          if (tA == null) return 1;
                          if (tB == null) return -1;
                          return tB.compareTo(tA);
                        });

                        final filteredDocs = docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final type = data['type']?.toString().toLowerCase() ?? '';
                          final title = data['title']?.toString().toLowerCase() ?? '';
                          final subtitle = (data['message'] ?? data['subtitle'])?.toString().toLowerCase() ?? '';

                          bool matchesFilter = true;
                          if (_selectedFilter == 'Jobs') {
                            matchesFilter = type == 'job' || type == 'application';
                          } else if (_selectedFilter == 'Messages') {
                            matchesFilter = type == 'message' || type == 'chat';
                          }

                          bool matchesSearch = true;
                          if (_searchQuery.isNotEmpty) {
                            matchesSearch = title.contains(_searchQuery.toLowerCase()) || 
                                            subtitle.contains(_searchQuery.toLowerCase());
                          }

                          return matchesFilter && matchesSearch;
                        }).toList();

                        if (filteredDocs.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Center(
                              child: Text(
                                'No notifications found.',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            final doc = filteredDocs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            
                            return GestureDetector(
                              onTap: () => _markAsReadAndNavigate(doc.id, data['actionRoute'] ?? data['route']),
                              child: _NotificationItem(
                                title: data['title'] ?? 'Notification',
                                subtitle: data['message'] ?? data['subtitle'] ?? '',
                                actionLabel: data['actionLabel'],
                                onAction: data['actionLabel'] != null 
                                  ? () => _markAsReadAndNavigate(doc.id, data['actionRoute'] ?? data['route'])
                                  : null,
                                isRead: data['isRead'] ?? false,
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

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingXS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryNavy : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isRead;

  const _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.onAction,
    this.actionLabel,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRead ? Colors.transparent : AppColors.primaryOrange,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: '$title : ',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(text: subtitle),
                    ],
                  ),
                ),
                if (actionLabel != null && actionLabel!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.paddingS),
                  GestureDetector(
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                      ),
                      child: Text(
                        actionLabel!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}