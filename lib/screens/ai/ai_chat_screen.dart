import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../services/ai_service.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final AIService _aiService = AIService();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add({
      'role': 'assistant',
      'content':
          'Hello! 👋 I\'m GoJobs Assistant. How can I help you today? I can help you find jobs, guide you through the app, or give career advice!',
    });
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
    if (text.isEmpty || _isLoading) return;

    _messageController.clear();

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });

    _scrollToBottom();

    final response = await _aiService.getChatResponse(
      userMessage: text,
      conversationHistory: _messages
          .where((m) => m['role'] != 'assistant' || _messages.indexOf(m) > 0)
          .toList(),
    );

    setState(() {
      _messages.add({'role': 'assistant', 'content': response});
      _isLoading = false;
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryNavy, Color(0xFF1a1850)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: const Icon(
                      Icons.smart_toy_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GoJobs Assistant',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '● Always Online',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.green,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                      border: Border.all(
                          color: AppColors.primaryOrange.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'AI Powered',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryOrange,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _TypingIndicator();
                  }
                  final msg = _messages[index];
                  final isMe = msg['role'] == 'user';
                  return _ChatBubble(
                    text: msg['content']!,
                    isMe: isMe,
                  );
                },
              ),
            ),

            // Quick suggestions
            if (_messages.length == 1) ...[
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL),
                  children: [
                    _SuggestionChip(
                      label: 'How do I apply for a job?',
                      onTap: () {
                        _messageController.text =
                            'How do I apply for a job?';
                        _sendMessage();
                      },
                    ),
                    const SizedBox(width: AppDimensions.paddingS),
                    _SuggestionChip(
                      label: 'How do I post a job?',
                      onTap: () {
                        _messageController.text = 'How do I post a job?';
                        _sendMessage();
                      },
                    ),
                    const SizedBox(width: AppDimensions.paddingS),
                    _SuggestionChip(
                      label: 'Career advice',
                      onTap: () {
                        _messageController.text =
                            'Give me career advice for Jordan job market';
                        _sendMessage();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
            ],

            // Input bar
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F5),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Ask me anything...',
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          filled: false,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingS),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryNavy,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
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
  final bool isMe;

  const _ChatBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingS),
          ],
          Flexible(
            child: Container(
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
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            child: Row(
              children: [
                Text(
                  'Thinking...',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingXS),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingXS,
        ),
        decoration: BoxDecoration(
          color: AppColors.purpleButton,
          borderRadius:
              BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(color: AppColors.purpleButtonBorder),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primaryNavy,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}