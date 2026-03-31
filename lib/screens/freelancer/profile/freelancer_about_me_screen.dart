import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class FreelancerAboutMeScreen extends StatefulWidget {
  const FreelancerAboutMeScreen({super.key});

  @override
  State<FreelancerAboutMeScreen> createState() =>
      _FreelancerAboutMeScreenState();
}

class _FreelancerAboutMeScreenState
    extends State<FreelancerAboutMeScreen> {
  final _aboutController = TextEditingController();

  @override
  void dispose() {
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.paddingL),

              GestureDetector(
                onTap: () => context.go('/freelancer/profile'),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              Text(
                'About me',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              Container(
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: TextField(
                  controller: _aboutController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Tell me about you.',
                    hintStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(
                              AppDimensions.radiusXL),
                        ),
                      ),
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(
                            AppDimensions.paddingXL),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.divider,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusFull),
                              ),
                            ),
                            const SizedBox(
                                height: AppDimensions.paddingL),
                            Text(
                              'Save Changes ?',
                              style: AppTextStyles.heading3.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                                height: AppDimensions.paddingS),
                            Text(
                              'Are you sure you want to change what you entered?',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                                height: AppDimensions.paddingL),
                            SizedBox(
                              width: double.infinity,
                              height: AppDimensions.buttonHeight,
                              child: ElevatedButton(
                                onPressed: () => context
                                    .go('/freelancer/profile'),
                                child: Text('SAVE CHANGES',
                                    style:
                                        AppTextStyles.buttonText),
                              ),
                            ),
                            const SizedBox(
                                height: AppDimensions.paddingM),
                            SizedBox(
                              width: double.infinity,
                              height: AppDimensions.buttonHeight,
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppColors
                                          .purpleButtonBorder),
                                  backgroundColor:
                                      AppColors.purpleButton,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            AppDimensions.radiusL),
                                  ),
                                ),
                                child: Text(
                                  'CONTINUE EDITING',
                                  style:
                                      AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primaryNavy,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                                height: AppDimensions.paddingL),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Text('SAVE', style: AppTextStyles.buttonText),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),
            ],
          ),
        ),
      ),
    );
  }
}