import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/company_bottom_nav.dart';

class CompanyNotificationsScreen extends StatefulWidget {
  const CompanyNotificationsScreen({super.key});

  @override
  State<CompanyNotificationsScreen> createState() => _CompanyNotificationsScreenState();
}

class _CompanyNotificationsScreenState extends State<CompanyNotificationsScreen> {
  String _currentFilter = 'All'; // Can be 'All', 'Jobs', 'Messages', 'Applications'

  Future<void> _markAsReadAndNavigate(String docId, String? route) async {
    try {
      // Mark as read in Firebase
      await FirebaseFirestore.instance.collection('notifications').doc(docId).update({
        'isRead': true,
      });
      // Navigate if a route was provided
      if (route != null && route.isNotEmpty && mounted) {
        context.go(route);
      }
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: AppDimensions.paddingL),

                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.menu, color: AppColors.textSecondary),
                                const SizedBox(width: AppDimensions.paddingS),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search notifications',
                                      hintStyle: AppTextStyles.bodySmall,
                                      border: InputBorder.none,
                                      filled: false,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.search, color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingM),
                        GestureDetector(
                          onTap: () => context.go('/company/profile'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                              child: Image.asset('assets/images/company_logo.png', fit: BoxFit.contain),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // Filter tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _currentFilter = 'All'),
                          child: _FilterTab(label: 'All', isSelected: _currentFilter == 'All'),
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        GestureDetector(
                          onTap: () => setState(() => _currentFilter = 'Jobs'),
                          child: _FilterTab(label: 'Jobs', isSelected: _currentFilter == 'Jobs'),
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        GestureDetector(
                          onTap: () => setState(() => _currentFilter = 'Messages'),
                          child: _FilterTab(label: 'Messages', isSelected: _currentFilter == 'Messages'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // LIVE Firebase Notifications
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      // Only fetch notifications sent to this specific company
                      stream: FirebaseFirestore.instance
                          .collection('notifications')
                          .where('recipientId', isEqualTo: currentUserId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return const Center(child: Text('Error loading notifications'));
                        }

                        var docs = snapshot.data?.docs ?? [];

                        // 1. Filter locally based on the selected tab
                        if (_currentFilter != 'All') {
                          docs = docs.where((doc) {
                            final type = (doc.data() as Map)['type']?.toString() ?? '';
                            if (_currentFilter == 'Jobs') return type == 'job' || type == 'application';
                            if (_currentFilter == 'Messages') return type == 'message';
                            return true;
                          }).toList();
                        }

                        // 2. Sort locally by newest first (avoids needing a complex Firebase Index)
                        final sortedDocs = docs.toList();
                        sortedDocs.sort((a, b) {
                          final aTime = (a.data() as Map)['createdAt'] as Timestamp?;
                          final bTime = (b.data() as Map)['createdAt'] as Timestamp?;
                          if (aTime == null || bTime == null) return 0;
                          return bTime.compareTo(aTime);
                        });

                        if (sortedDocs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.notifications_none, color: AppColors.textSecondary, size: 60),
                                const SizedBox(height: AppDimensions.paddingM),
                                Text(
                                  'No new notifications',
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                          itemCount: sortedDocs.length,
                          itemBuilder: (context, index) {
                            final data = sortedDocs[index].data() as Map<String, dynamic>;
                            final docId = sortedDocs[index].id;
                            
                            final title = data['title']?.toString() ?? 'Notification';
                            final subtitle = data['subtitle']?.toString() ?? '';
                            final actionLabel = data['actionLabel']?.toString();
                            final route = data['route']?.toString();
                            final isRead = data['isRead'] as bool? ?? false;
                            
                            final createdAt = data['createdAt'] as Timestamp?;
                            final timeString = createdAt != null 
                                ? DateFormat('MMM dd, hh:mm a').format(createdAt.toDate())
                                : '';

                            return _NotificationItem(
                              title: title,
                              subtitle: '$subtitle\n$timeString',
                              actionLabel: actionLabel,
                              isRead: isRead,
                              onAction: actionLabel != null ? () => _markAsReadAndNavigate(docId, route) : null,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const CompanyBottomNav(currentIndex: -1),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterTab({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: AppDimensions.paddingXS),
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
              color: isRead ? Colors.transparent : AppColors.companyGold,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                    children: [
                      TextSpan(
                        text: '$title : ',
                        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      TextSpan(text: subtitle),
                    ],
                  ),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(height: AppDimensions.paddingS),
                  GestureDetector(
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: AppDimensions.paddingXS),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Text(
                        actionLabel!,
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontSize: 10),
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