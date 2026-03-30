import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class StudentChatScreen extends StatefulWidget {
  const StudentChatScreen({super.key});

  @override
  State<StudentChatScreen> createState() => _StudentChatScreenState();
}

class _StudentChatScreenState extends State<StudentChatScreen> {
  final _messageController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hello sir, Good Morning', 'isMe': true, 'time': '09:30 am'},
    {'text': 'Morning, Can i help you ?', 'isMe': false, 'time': '09:31 am'},
    {
      'text': 'I have a few questions regarding the 2nd activity of my Ai course',
      'isMe': true,
      'time': '09:33 am'
    },
    {
      'text': 'Oh yes, i already received your questions, will update you !',
      'isMe': false,
      'time': '09:35 am'
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    onTap: () =>context.pop(),
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
                      'Z',
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
                          'Zaid smadi',
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
                 
                  const Icon(
                    Icons.search,
                    color: AppColors.primaryOrange,
                  ),
                  const SizedBox(width: AppDimensions.paddingS),
                  const Icon(
                    Icons.more_vert,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = msg['isMe'] as bool;
                  return _ChatBubble(
                    text: msg['text'] as String,
                    time: msg['time'] as String,
                    isMe: isMe,
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
                  const Icon(
                    Icons.attach_file_outlined,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.paddingS),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Write your massage',
                        hintStyle: AppTextStyles.bodySmall,
                        border: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_messageController.text.isNotEmpty) {
                        setState(() {
                          _messages.add({
                            'text': _messageController.text,
                            'isMe': true,
                            'time': 'Now',
                          });
                          _messageController.clear();
                        });
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryNavy,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
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

  const _ChatBubble({
    required this.text,
    required this.time,
    required this.isMe,
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
                'Z',
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