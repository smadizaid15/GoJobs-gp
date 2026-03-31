import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class FreelancerSkillsScreen extends StatefulWidget {
  const FreelancerSkillsScreen({super.key});

  @override
  State<FreelancerSkillsScreen> createState() =>
      _FreelancerSkillsScreenState();
}

class _FreelancerSkillsScreenState
    extends State<FreelancerSkillsScreen> {
  final _searchController = TextEditingController();
  String _search = '';

  final List<String> _allSkills = [
    'Pipe installation',
    'Wiring',
    'Welding',
    'Using drilling tools',
    'Repairing ACs',
    'Drain Cleaning',
    'Leak detection',
    'Sewer line maintanence',
    'Shower installation',
    'Pump installation',
    'Carpentry',
    'Painting',
    'Electrical work',
    'Tiling',
  ];

  final List<String> _selectedSkills = [
    'Wiring',
    'Welding',
    'Leak detection',
    'Pipe installation',
    'Shower installation',
    'Sewer line maintanence',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _allSkills
        .where((s) =>
            s.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/freelancer/profile'),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingL),

                  Text(
                    'Add Skill',
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // Search bar
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: AppColors.textSecondary),
                        const SizedBox(width: AppDimensions.paddingS),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) =>
                                setState(() => _search = val),
                            decoration: InputDecoration(
                              hintText: 'plumbing',
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
                            child: const Icon(Icons.close,
                                color: AppColors.textSecondary,
                                size: 18),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Skills list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final skill = filtered[index];
                  final isSelected =
                      _selectedSkills.contains(skill);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedSkills.remove(skill);
                        } else {
                          _selectedSkills.add(skill);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingS,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            skill,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isSelected
                                  ? AppColors.primaryNavy
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check,
                                color: AppColors.primaryNavy,
                                size: 18),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Selected skills
            if (_selectedSkills.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(AppDimensions.paddingL),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skill (${_selectedSkills.length})',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Wrap(
                      spacing: AppDimensions.paddingXS,
                      runSpacing: AppDimensions.paddingXS,
                      children: _selectedSkills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: AppDimensions.paddingXS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(skill,
                                  style: AppTextStyles.bodySmall),
                              const SizedBox(
                                  width: AppDimensions.paddingXS),
                              GestureDetector(
                                onTap: () => setState(() =>
                                    _selectedSkills.remove(skill)),
                                child: const Icon(Icons.close,
                                    size: 14,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
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
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}