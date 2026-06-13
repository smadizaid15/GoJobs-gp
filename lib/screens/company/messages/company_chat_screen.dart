import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class CompanyChatScreen extends StatefulWidget {
  final Map<String, dynamic>? chatData;

  const CompanyChatScreen({
    super.key,
    this.chatData,
  });

  @override
  State<CompanyChatScreen> createState() => _CompanyChatScreenState();
}

class _CompanyChatScreenState extends State<CompanyChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  late String _chatId;
  late String _receiverId;
  late String _receiverName;

  @override
  void initState() {
    super.initState();
    // Extract data passed from Inbox
    _chatId = widget.chatData?['chatId'] ?? '';
    _receiverId = widget.chatData?['receiverId'] ?? '';
    _receiverName = widget.chatData?['receiverName'] ?? 'Applicant';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || _chatId.isEmpty) return;

    _messageController.clear();

    final timestamp = FieldValue.serverTimestamp();

    // 1. Add message to the subcollection
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'text': text,
      'timestamp': timestamp,
    });

    // 2. Update the parent chat document for the inbox preview
    await FirebaseFirestore.instance.collection('chats').doc(_chatId).update({
      'lastMessage': text,
      'updatedAt': timestamp,
      'unread_$_receiverId': FieldValue.increment(1), // Adds an unread dot for the receiver
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingM,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.inputFill,
                    child: Text(
                      _receiverName.isNotEmpty ? _receiverName[0].toUpperCase() : 'U',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _receiverName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '● Online', // You can make this dynamic later
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.green,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.search, color: AppColors.companyGold),
                  const SizedBox(width: AppDimensions.paddingM),
                  const Icon(Icons.more_vert, color: AppColors.textPrimary),
                ],
              ),
            ),

            // Messages Stream
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(_chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.companyGold));
                  }

                  final messageDocs = snapshot.data?.docs ?? [];
                  
                  // Auto scroll when new messages arrive
                  _scrollToBottom();

                  if (messageDocs.isEmpty) {
                    return Center(
                      child: Text(
                        'No messages yet. Say hello!',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    itemCount: messageDocs.length,
                    itemBuilder: (context, index) {
                      final data = messageDocs[index].data() as Map<String, dynamic>;
                      final isMe = data['senderId'] == currentUserId;
                      
                      // Format time safely
                      final timestamp = data['timestamp'] as Timestamp?;
                      String timeString = 'Now';
                      if (timestamp != null) {
                        final date = timestamp.toDate();
                        timeString = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                      }

                      return _ChatBubble(
                        text: data['text'] ?? '',
                        time: timeString,
                        isMe: isMe,
                        senderInitial: isMe ? 'M' : (_receiverName.isNotEmpty ? _receiverName[0].toUpperCase() : 'U'),
                      );
                    },
                  );
                },
              ),
            ),

            // Input bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingM,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.attach_file_outlined, color: AppColors.textSecondary),
                  const SizedBox(width: AppDimensions.paddingS),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Write your message',
                        hintStyle: AppTextStyles.bodySmall,
                        border: InputBorder.none,
                        filled: false,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.companyGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final String senderInitial;

  const _ChatBubble({
    required this.text,
    required this.time,
    required this.isMe,
    required this.senderInitial,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.inputFill,
              child: Text(
                senderInitial,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingS),
          ],
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primaryNavy : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppDimensions.radiusL),
                    topRight: const Radius.circular(AppDimensions.radiusL),
                    bottomLeft: isMe
                        ? const Radius.circular(AppDimensions.radiusL)
                        : Radius.zero,
                    bottomRight: isMe
                        ? Radius.zero
                        : const Radius.circular(AppDimensions.radiusL),
                  ),
                ),
                child: Text(
                  text,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isMe ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}