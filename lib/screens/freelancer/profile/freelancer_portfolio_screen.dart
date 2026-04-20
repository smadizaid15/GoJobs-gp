import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class FreelancerPortfolioScreen extends StatefulWidget {
  const FreelancerPortfolioScreen({super.key});

  @override
  State<FreelancerPortfolioScreen> createState() =>
      _FreelancerPortfolioScreenState();
}

class _FreelancerPortfolioScreenState
    extends State<FreelancerPortfolioScreen> {
  bool _hasPhotos = false;

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
                'Add Photos here..',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Upload pic
              GestureDetector(
                onTap: () => setState(() => _hasPhotos = true),
                child: Container(
                  width: double.infinity,
                  height: _hasPhotos ? 200 : 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: _hasPhotos
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusL),
                              child: Container(
                                color: AppColors.inputFill,
                                child: const Center(
                                  child: Icon(
                                    Icons.image,
                                    color: AppColors.textSecondary,
                                    size: 60,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.upload_outlined,
                              color: AppColors.textSecondary,
                              size: 40,
                            ),
                            const SizedBox(
                                height: AppDimensions.paddingS),
                            Text(
                              'Drag and drop files here',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(
                                height: AppDimensions.paddingXS),
                            Text(
                              '< or >',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(
                                height: AppDimensions.paddingS),
                            OutlinedButton(
                              onPressed: () =>
                                  setState(() => _hasPhotos = true),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.purpleButtonBorder),
                                backgroundColor: AppColors.purpleButton,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusFull),
                                ),
                              ),
                              child: Text(
                                'UPLOAD',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryNavy,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const Spacer(),

              if (_hasPhotos) ...[
                // Save changes 
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
                                    style: AppTextStyles.bodySmall
                                        .copyWith(
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
                    child: Text('SAVE',
                        style: AppTextStyles.buttonText),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.go('/freelancer/profile'),
                    child: Text('SAVE',
                        style: AppTextStyles.buttonText),
                  ),
                ),
              ],

              const SizedBox(height: AppDimensions.paddingXL),
            ],
          ),
        ),
      ),
    );
  }
}