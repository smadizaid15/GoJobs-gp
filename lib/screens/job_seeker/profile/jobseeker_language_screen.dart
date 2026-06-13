import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class JobseekerLanguageScreen extends StatefulWidget {
  const JobseekerLanguageScreen({super.key});

  @override
  State<JobseekerLanguageScreen> createState() =>
      _JobseekerLanguageScreenState();
}

class _JobseekerLanguageScreenState
    extends State<JobseekerLanguageScreen> {
  bool _showSearch = false;
  String _search = '';
  final _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  List<Map<String, dynamic>> _languages = [];

  final List<Map<String, String>> _allLanguages = [
    {'name': 'Arabic', 'flag': '🇸🇦'},
    {'name': 'English', 'flag': '🇬🇧'},
    {'name': 'French', 'flag': '🇫🇷'},
    {'name': 'German', 'flag': '🇩🇪'},
    {'name': 'Italian', 'flag': '🇮🇹'},
    {'name': 'Hindi', 'flag': '🇮🇳'},
    {'name': 'Malaysian', 'flag': '🇲🇾'},
    {'name': 'Indonesian', 'flag': '🇮🇩'},
    {'name': 'Japanese', 'flag': '🇯🇵'},
    {'name': 'Korean', 'flag': '🇰🇷'},
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data['languages'] != null) {
            setState(() {
              _languages = List<Map<String, dynamic>>.from(data['languages']);
            });
          }
        }
      } catch (e) {
        debugPrint("Error loading languages: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveLanguages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'languages': _languages,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Languages saved!'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _allLanguages
        .where((l) => l['name']!
            .toLowerCase()
            .contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.paddingL),

              
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

           
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Language',
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showSearch = !_showSearch),
                    child: Row(
                      children: [
                        Text(
                          'Add',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                            width: AppDimensions.paddingXS),
                        const Icon(
                          Icons.add,
                          color: AppColors.primaryNavy,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingL),

             
              ..._languages.map((lang) {
                return Container(
                  margin: const EdgeInsets.only(
                      bottom: AppDimensions.paddingM),
                  padding:
                      const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM),
                  ),
                  child: Row(
                    children: [
                      Text(
                        lang['flag'] ?? '🌐',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${lang['name']} (${lang['level'] ?? 'Basic'})',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Added to profile',
                              style: AppTextStyles.bodySmall
                                  .copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _languages.remove(lang));
                        },
                        child: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              
              if (_showSearch) ...[
                const SizedBox(height: AppDimensions.paddingM),

                Text(
                  'Add Language',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingM),

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
                            hintText: 'Search language',
                            hintStyle: AppTextStyles.bodySmall,
                            border: InputBorder.none,
                            filled: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingM),

                ...filtered.map((lang) {
                  final isAdded = _languages
                      .any((l) => l['name'] == lang['name']);
                  return GestureDetector(
                    onTap: () {
                      if (!isAdded) {
                        setState(() {
                          _languages.add({
                            'name': lang['name']!,
                            'level': 'Fluent',
                            'flag': lang['flag']!,
                          });
                          _showSearch = false;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                        horizontal: AppDimensions.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: isAdded
                            ? AppColors.purpleButton
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(lang['flag']!,
                                  style: const TextStyle(
                                      fontSize: 20)),
                              const SizedBox(
                                  width: AppDimensions.paddingM),
                              Text(
                                lang['name']!,
                                style:
                                    AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          if (isAdded)
                            const Icon(Icons.check,
                                color: AppColors.primaryNavy,
                                size: 18),
                        ],
                      ),
                    ),
                  );
                }),
              ],

              const SizedBox(height: AppDimensions.paddingXL),

             
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveLanguages,
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('SAVE', style: AppTextStyles.buttonText),
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