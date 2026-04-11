import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../services/ai_service.dart';

class AIJobDescriptionScreen extends StatefulWidget {
  const AIJobDescriptionScreen({super.key});

  @override
  State<AIJobDescriptionScreen> createState() =>
      _AIJobDescriptionScreenState();
}

class _AIJobDescriptionScreenState extends State<AIJobDescriptionScreen> {
  final AIService _aiService = AIService();
  final _jobTitleController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedJobType = 'Full time';
  String? _generatedDescription;
  bool _isLoading = false;

  final List<String> _jobTypes = [
    'Full time',
    'Part time',
    'Contract',
    'Temporary',
    'Internship',
  ];

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _generateDescription() async {
    if (_jobTitleController.text.isEmpty ||
        _companyNameController.text.isEmpty ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final description = await _aiService.generateJobDescription(
        jobTitle: _jobTitleController.text.trim(),
        companyName: _companyNameController.text.trim(),
        location: _locationController.text.trim(),
        jobType: _selectedJobType,
      );
      setState(() => _generatedDescription = description);
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
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Job Description',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Generate with AI',
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
                      color: AppColors.companyGold.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                      border: Border.all(
                          color: AppColors.companyGold.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'AI Powered',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.companyGold,
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
                    Text(
                      'Fill in job details and let AI write the description for you!',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    Text('Job Title', style: AppTextStyles.labelText),
                    const SizedBox(height: AppDimensions.paddingXS),
                    TextField(
                      controller: _jobTitleController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Head Barista',
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    Text('Company Name', style: AppTextStyles.labelText),
                    const SizedBox(height: AppDimensions.paddingXS),
                    TextField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Calma Space',
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    Text('Location', style: AppTextStyles.labelText),
                    const SizedBox(height: AppDimensions.paddingXS),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Irbid, Jordan',
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    Text('Job Type', style: AppTextStyles.labelText),
                    const SizedBox(height: AppDimensions.paddingS),

                    Wrap(
                      spacing: AppDimensions.paddingXS,
                      children: _jobTypes.map((type) {
                        final isSelected = _selectedJobType == type;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedJobType = type),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                              vertical: AppDimensions.paddingXS,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryNavy
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryNavy
                                    : AppColors.divider,
                              ),
                            ),
                            child: Text(
                              type,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _generateDescription,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.companyGold,
                        ),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.smart_toy_outlined,
                                color: Colors.white,
                              ),
                        label: Text(
                          _isLoading
                              ? 'Generating...'
                              : 'GENERATE DESCRIPTION',
                          style: AppTextStyles.buttonText,
                        ),
                      ),
                    ),

                    if (_generatedDescription != null) ...[
                      const SizedBox(height: AppDimensions.paddingL),

                      Text(
                        'Generated Description',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingS),

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusL),
                          border: Border.all(
                              color: AppColors.companyGold.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.smart_toy_outlined,
                                      color: AppColors.companyGold,
                                      size: 16,
                                    ),
                                    const SizedBox(
                                        width: AppDimensions.paddingXS),
                                    Text(
                                      'AI Generated',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.companyGold,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: _generateDescription,
                                  child: const Icon(
                                    Icons.refresh,
                                    color: AppColors.textSecondary,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.paddingS),
                            Text(
                              _generatedDescription!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingM),

                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton(
                          onPressed: () {
                            context.pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.companyGold,
                          ),
                          child: Text(
                            'USE THIS DESCRIPTION',
                            style: AppTextStyles.buttonText,
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