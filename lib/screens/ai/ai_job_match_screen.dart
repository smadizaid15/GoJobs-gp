import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../services/ai_service.dart';

class AIJobMatchScreen extends StatefulWidget {
  final Map<String, dynamic>? job;

  const AIJobMatchScreen({super.key, this.job});

  @override
  State<AIJobMatchScreen> createState() => _AIJobMatchScreenState();
}

class _AIJobMatchScreenState extends State<AIJobMatchScreen> {
  final AIService _aiService = AIService();
  bool _isLoading = false;
  Map<String, dynamic>? _matchResult;

  final List<String> _userSkills = [
    'Leadership',
    'Teamwork',
    'Communication',
    'Management',
  ];
  final String _userLocation = 'Irbid, Jordan';
  final String _userExperience = '2 years experience in management';

  Future<void> _getMatchScore() async {
    setState(() => _isLoading = true);
    try {
      final result = await _aiService.getJobMatchScore(
        jobTitle: widget.job?['title'] ?? 'Head Manager',
        jobDescription: widget.job?['description'] ??
            'The Head Manager oversees all daily operations.',
        jobLocation: widget.job?['location'] ?? 'Irbid, Jordan',
        jobType: widget.job?['employmentType'] ?? 'Full time',
        userSkills: _userSkills,
        userLocation: _userLocation,
        userExperience: _userExperience,
      );
      setState(() => _matchResult = result);
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

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return AppColors.primaryOrange;
    if (score >= 40) return Colors.orange;
    return AppColors.error;
  }

  @override
  void initState() {
    super.initState();
    _getMatchScore();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.job?['title'] ?? 'Head Manager';
    final location = widget.job?['location'] ?? 'Irbid, Jordan';
    final jobType = widget.job?['employmentType'] ?? 'Full time';

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
                    child:
                        const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job Match Score',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'AI powered analysis',
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
                  children: [
                    // Job info card
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(AppDimensions.paddingM),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusL),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '$location • $jobType',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

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
                              'Analyzing your profile...',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_matchResult != null) ...[
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
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CircularProgressIndicator(
                                    value:
                                        (_matchResult!['score'] as int) /
                                            100,
                                    strokeWidth: 10,
                                    backgroundColor: AppColors.inputFill,
                                    color: _getScoreColor(
                                        _matchResult!['score'] as int),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${_matchResult!['score']}%',
                                      style:
                                          AppTextStyles.heading2.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _getScoreColor(
                                            _matchResult!['score'] as int),
                                      ),
                                    ),
                                    Text(
                                      'Match',
                                      style:
                                          AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: AppDimensions.paddingM),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingL,
                                vertical: AppDimensions.paddingXS,
                              ),
                              decoration: BoxDecoration(
                                color: _getScoreColor(
                                        _matchResult!['score'] as int)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusFull),
                              ),
                              child: Text(
                                _matchResult!['level'] as String,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: _getScoreColor(
                                      _matchResult!['score'] as int),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingM),

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusL),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Why this score?',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingM),
                            ...(_matchResult!['reasons'] as List<dynamic>)
                                .map((reason) => Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: AppDimensions.paddingS),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green,
                                            size: 18,
                                          ),
                                          const SizedBox(
                                              width:
                                                  AppDimensions.paddingS),
                                          Expanded(
                                            child: Text(
                                              reason as String,
                                              style: AppTextStyles
                                                  .bodySmall
                                                  .copyWith(
                                                color:
                                                    AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingM),

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.purpleButton,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusL),
                          border: Border.all(
                              color: AppColors.purpleButtonBorder),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.primaryNavy,
                              size: 20,
                            ),
                            const SizedBox(width: AppDimensions.paddingS),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tip to improve',
                                    style: AppTextStyles.bodySmall
                                        .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryNavy,
                                    ),
                                  ),
                                  Text(
                                    _matchResult!['tip'] as String,
                                    style: AppTextStyles.bodySmall
                                        .copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingL),

                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton(
                          onPressed: () => context.push(
                              '/jobseeker/upload-cv',
                              extra: widget.job),
                          child: Text('APPLY NOW',
                              style: AppTextStyles.buttonText),
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