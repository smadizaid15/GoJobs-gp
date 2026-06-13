import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/freelancer_bottom_nav.dart';

class FreelancerNotificationsScreen extends StatefulWidget {
  const FreelancerNotificationsScreen({super.key});

  @override
  State<FreelancerNotificationsScreen> createState() => _FreelancerNotificationsScreenState();
}

class _FreelancerNotificationsScreenState extends State<FreelancerNotificationsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _profileImageUrl = doc.data()?['profileImageUrl'] ?? doc.data()?['logoUrl'];
        });
      }
    }
  }

  Future<void> _markAsRead(String docId) async {
    await _firestore.collection('notifications').doc(docId).update({'isRead': true});
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: AppDimensions.paddingL),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Notifications',
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/freelancer/profile'),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primaryNavy,
                            backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
                            child: _profileImageUrl == null
                                ? Text(
                                    'F',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // LIVE NOTIFICATIONS FEED
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('notifications')
                          .where('userId', isEqualTo: currentUserId)
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return const Center(child: Text('Error loading notifications'));
                        }

                        final docs = snapshot.data?.docs ?? [];

                        if (docs.isEmpty) {
                          return Center(
                            child: Text(
                              'You have no notifications',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;

                            return GestureDetector(
                              onTap: () {
                                if (!(data['isRead'] as bool? ?? false)) {
                                  _markAsRead(doc.id);
                                }
                              },
                              child: _NotificationItem(
                                title: data['title'] ?? 'Notification',
                                subtitle: data['message'] ?? '',
                                actionLabel: data['actionLabel'],
                                isRead: data['isRead'] ?? false,
                                onAction: data['actionRoute'] != null 
                                    ? () {
                                        _markAsRead(doc.id);
                                        context.go(data['actionRoute']);
                                      } 
                                    : null,
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
            const FreelancerBottomNav(currentIndex: -1),
          ],
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
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
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
                if (actionLabel != null) ...[
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
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
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