import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../services/message_service.dart';
import '../../../models/message_model.dart';
import '../../../providers/auth_provider.dart';

class CompanyChatScreen extends StatefulWidget {
  final String? receiverId;
  final String? receiverName;

  const CompanyChatScreen({
    super.key,
    this.receiverId,
    this.receiverName,
  });

  @override
  State<CompanyChatScreen> createState() => _CompanyChatScreenState();
}

class _CompanyChatScreenState extends State<CompanyChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final MessageService _messageService = MessageService();

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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.uid ?? '';
    final receiverId = widget.receiverId ?? 'dummy_receiver';
    final chatId = _messageService.getChatId(currentUserId, receiverId);

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
                      widget.receiverName?.isNotEmpty == true
                          ? widget.receiverName![0].toUpperCase()
                          : 'U',
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
                          widget.receiverName ?? 'Chat',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '● Online',
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

            // Messages
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                stream: _messageService.getMessages(chatId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data ?? [];
                  _scrollToBottom();

                  if (messages.isEmpty) {
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
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == currentUserId;
                      return _ChatBubble(
                        text: msg.text,
                        time: msg.timestamp != null
                            ? '${msg.timestamp!.hour}:${msg.timestamp!.minute.toString().padLeft(2, '0')}'
                            : 'Now',
                        isMe: isMe,
                        senderInitial: widget.receiverName?.isNotEmpty == true
                            ? widget.receiverName![0].toUpperCase()
                            : 'U',
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
                  const Icon(Icons.attach_file_outlined,
                      color: AppColors.textSecondary),
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
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_messageController.text.isNotEmpty) {
                        final text = _messageController.text;
                        _messageController.clear();
                        await _messageService.sendMessage(
                          chatId: chatId,
                          senderId: currentUserId,
                          text: text,
                        );
                        _scrollToBottom();
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.companyGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send,
                          color: Colors.white, size: 18),
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