import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class CompanyLocationPicker extends StatefulWidget {
  const CompanyLocationPicker({super.key});

  @override
  State<CompanyLocationPicker> createState() => _CompanyLocationPickerState();
}

class _CompanyLocationPickerState extends State<CompanyLocationPicker> {
  final _searchController = TextEditingController();
  String _search = '';

  final List<String> _locations = [
    'Sameh mall, Irbid, Jordan',
    'Uni street, Irbid, Jordan',
    'Sports city, Irbid, Jordan',
    'Thaqafa roundabout, Irbid, Jordan',
    'Downtown, Amman, Jordan',
    'Abdali, Amman, Jordan',
    'Swefieh, Amman, Jordan',
    'Zarqa, Jordan',
    'Aqaba, Jordan',
    'Madaba, Jordan',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _locations
        .where((l) => l.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.paddingL),

            // Back + title
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
              ),
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
                  Text(
                    'Location',
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Search 
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
              ),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                ),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.textSecondary),
                    const SizedBox(width: AppDimensions.paddingS),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _search = val),
                        decoration: InputDecoration(
                          hintText: 'Search location',
                          hintStyle: AppTextStyles.bodySmall,
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),
                    if (_search.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _search = '');
                        },
                        child: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.paddingM),

            // Location list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => context.pop(filtered[index]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                      ),
                      child: Text(
                        filtered[index],
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
