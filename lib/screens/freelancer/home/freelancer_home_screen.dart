import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/freelancer_bottom_nav.dart';

class FreelancerHomeScreen extends StatelessWidget {
  const FreelancerHomeScreen({super.key});

  Future<void> _updateRequestStatus(BuildContext context, String requestId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('freelancer_requests')
          .doc(requestId)
          .update({'status': status});
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'accepted' ? 'Request Accepted!' : 'Request Declined',
            ),
            backgroundColor: status == 'accepted' ? Colors.green : AppColors.error,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error updating request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF0F0F5),
            body: Center(child: CircularProgressIndicator(color: AppColors.primaryOrange)),
          );
        }

        final currentUserId = authSnapshot.data?.uid ?? '';

        if (currentUserId.isEmpty) {
          return const Scaffold(
            backgroundColor: Color(0xFFF0F0F5),
            body: Center(child: Text('Loading user data...')),
          );
        }

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

                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUserId)
                              .snapshots(),
                          builder: (context, userSnapshot) {
                            String freelancerName = 'Freelancer';
                            String? profileImageUrl;

                            if (userSnapshot.hasData && userSnapshot.data!.exists) {
                              final data = userSnapshot.data!.data() as Map<String, dynamic>;
                              freelancerName = data['fullName']?.toString() ??
                                               data['displayName']?.toString() ?? 
                                               'Freelancer';
                              profileImageUrl = data['freelancerAvatarUrl']?.toString() ??
                                                data['profileImageUrl']?.toString();
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$freelancerName.',
                                      style: AppTextStyles.heading3.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppDimensions.paddingS,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryOrange.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                      ),
                                      child: Text(
                                        'Freelance',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.primaryOrange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => context.go('/freelancer/settings'),
                                      child: const Icon(
                                        Icons.settings_outlined,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: AppDimensions.paddingS),
                                    GestureDetector(
                                      onTap: () => context.push('/ai-chat'),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryNavy,
                                          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                        ),
                                        child: const Icon(
                                          Icons.smart_toy_outlined,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppDimensions.paddingS),
                                    GestureDetector(
                                      onTap: () => context.go('/freelancer/profile'),
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: AppColors.primaryNavy,
                                        backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                                            ? NetworkImage(profileImageUrl)
                                            : null,
                                        child: profileImageUrl == null || profileImageUrl.isEmpty
                                            ? Text(
                                                freelancerName.isNotEmpty ? freelancerName[0].toUpperCase() : 'F',
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
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: AppDimensions.paddingL),

                        Text(
                          'Pending jobs',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.paddingM),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('freelancer_requests')
                              .where('freelancerId', isEqualTo: currentUserId)
                              .where('status', isEqualTo: 'pending')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(child: Text('Error loading requests.'));
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final requests = snapshot.data?.docs ?? [];

                            if (requests.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXL),
                                child: Center(
                                  child: Text(
                                    'No pending requests right now.',
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: requests.length,
                              itemBuilder: (context, index) {
                                final requestData = requests[index].data() as Map<String, dynamic>;
                                final requestId = requests[index].id;
                                final clientId = requestData['clientId']?.toString() ?? '';

                                final createdAt = requestData['timestamp'] as Timestamp?;
                                final dateString = createdAt != null
                                    ? 'Posted on ${DateFormat('dd/MM/yy').format(createdAt.toDate())}'
                                    : 'Recently';

                                // THE FIX: Dynamically fetching the client's name so it's not a generic placeholder
                                return FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance.collection('users').doc(clientId).get(),
                                  builder: (context, clientSnapshot) {
                                    String clientName = 'A user';
                                    if (clientSnapshot.hasData && clientSnapshot.data!.exists) {
                                      final clientData = clientSnapshot.data!.data() as Map<String, dynamic>;
                                      clientName = clientData['fullName'] ?? clientData['displayName'] ?? 'A user';
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                                      child: _PendingJobCard(
                                        title: 'Request from $clientName',
                                        location: 'Needs your services',
                                        description: 'Accept to view details or message the client directly.',
                                        postedDate: dateString,
                                        onAccept: () => _updateRequestStatus(context, requestId, 'accepted'),
                                        onDecline: () => _updateRequestStatus(context, requestId, 'declined'),
                                        onMessage: () {
                                          // Passing the clientId and Name to the chat screen
                                          context.push(
                                            '/freelancer/chat', 
                                            extra: {
                                              'targetUserId': clientId,
                                              'targetUserName': clientName,
                                            }
                                          );
                                        },
                                      ),
                                    );
                                  }
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
                const FreelancerBottomNav(currentIndex: 0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PendingJobCard extends StatelessWidget {
  final String title;
  final String location;
  final String description;
  final String postedDate;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onMessage;

  const _PendingJobCard({
    required this.title,
    required this.location,
    required this.description,
    required this.postedDate,
    required this.onAccept,
    required this.onDecline,
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
              Expanded(
                child: Column(
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
                      location,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                postedDate,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
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
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onAccept,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryNavy),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
                  ),
                  child: Text(
                    'Accept',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryNavy),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingS),
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
                  ),
                  child: Text(
                    'Decline',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingS),
              Expanded(
                child: ElevatedButton(
                  onPressed: onMessage,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
                  ),
                  child: Text(
                    'Message',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
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