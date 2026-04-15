import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../services/ai_service.dart';

class AIInterviewPrepScreen extends StatefulWidget {
  final Map<String, dynamic>? job;

  const AIInterviewPrepScreen({super.key, this.job});

  @override
  State<AIInterviewPrepScreen> createState() =>
      _AIInterviewPrepScreenState();
}

class _AIInterviewPrepScreenState extends State<AIInterviewPrepScreen> {
  final AIService _aiService = AIService();
  bool _isLoading = false;
  List<String> _questions = [];
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _getQuestions();
  }

  Future<void> _getQuestions() async {
    setState(() {
      _isLoading = true;
      _expandedIndex = null;
    });
    try {
      final questions = await _aiService.getInterviewQuestions(
        jobTitle: widget.job?['title'] ?? 'Head Manager',
        jobDescription: widget.job?['description'] ??
            'The Head Manager oversees all daily operations of the coffee house, ensuring a smooth, efficient, and welcoming environment.',
      );
      setState(() => _questions = questions);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.job?['title'] ?? 'Head Manager';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          children: [
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
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interview Prep',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'AI powered questions',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
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
                      color:
                          AppColors.primaryOrange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull),
                      border: Border.all(
                          color: AppColors.primaryOrange
                              .withValues(alpha: 0.5)),
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job info
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(AppDimensions.paddingM),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusL),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.work_outline,
                              color: AppColors.primaryOrange),
                          const SizedBox(width: AppDimensions.paddingM),
                          Column(
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
                                'Prepare for your interview',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    Text(
                      'Likely Interview Questions',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingXS),

                    Text(
                      'Tap each question to practice your answer',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    if (_isLoading)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                            AppDimensions.paddingXL),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusL),
                        ),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(
                                height: AppDimensions.paddingM),
                            Text(
                              'Generating interview questions...',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...List.generate(_questions.length, (index) {
                        final isExpanded = _expandedIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _expandedIndex =
                                  isExpanded ? null : index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                bottom: AppDimensions.paddingM),
                            padding: const EdgeInsets.all(
                                AppDimensions.paddingM),
                            decoration: BoxDecoration(
                              color: isExpanded
                                  ? AppColors.purpleButton
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusL),
                              border: isExpanded
                                  ? Border.all(
                                      color:
                                          AppColors.purpleButtonBorder)
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: isExpanded
                                            ? AppColors.primaryNavy
                                            : AppColors.inputFill,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                            color: isExpanded
                                                ? Colors.white
                                                : AppColors.textSecondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        width: AppDimensions.paddingM),
                                    Expanded(
                                      child: Text(
                                        _questions[index],
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: isExpanded
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                                if (isExpanded) ...[
                                  const SizedBox(
                                      height: AppDimensions.paddingM),
                                  const Divider(
                                      color: AppColors.divider),
                                  const SizedBox(
                                      height: AppDimensions.paddingS),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.lightbulb_outline,
                                        color: AppColors.primaryNavy,
                                        size: 16,
                                      ),
                                      const SizedBox(
                                          width:
                                              AppDimensions.paddingXS),
                                      Text(
                                        'Practice your answer out loud!',
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                          color: AppColors.primaryNavy,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),

                    if (!_isLoading && _questions.isNotEmpty) ...[
                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: OutlinedButton.icon(
                          onPressed: _getQuestions,
                          icon: const Icon(Icons.refresh,
                              color: AppColors.primaryNavy),
                          label: Text(
                            'REGENERATE QUESTIONS',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryNavy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.purpleButtonBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusL),
                            ),
                            backgroundColor: AppColors.purpleButton,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppDimensions.paddingXL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}