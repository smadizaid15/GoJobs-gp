import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class StudentInternshipListScreen extends StatefulWidget {
  final String? category;
  const StudentInternshipListScreen({super.key, this.category});

  @override
  State<StudentInternshipListScreen> createState() => _StudentInternshipListScreenState();
}

class _StudentInternshipListScreenState extends State<StudentInternshipListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.paddingL),

         
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
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppDimensions.paddingS),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                              decoration: InputDecoration(
                                hintText: 'Search internships',
                                hintStyle: AppTextStyles.bodySmall,
                                border: InputBorder.none,
                                filled: false,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.tune,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingL),

            
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.category != null ? '${widget.category} Internships' : 'All Internships',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.paddingM),

         
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('jobs')
                    .where('jobType', isEqualTo: 'Internship')
                    .where('isActive', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading internships.'));
                  }

                  final docs = snapshot.data?.docs ?? [];

                 
                  final filteredInternships = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title']?.toString().toLowerCase() ?? '';
                    final cat = data['category']?.toString().toLowerCase() ?? '';

                    bool matchesSearch = title.contains(_searchQuery);
                    bool matchesCategory = widget.category == null || cat == widget.category!.toLowerCase();

                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filteredInternships.isEmpty) {
                    return Center(
                      child: Text(
                        'No internships found.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    itemCount: filteredInternships.length,
                    itemBuilder: (context, index) {
                      final doc = filteredInternships[index];
                      final data = doc.data() as Map<String, dynamic>;
                      
                      final jobDataForDetail = {
                        'id': doc.id,
                        ...data,
                      };

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                        child: _InternshipCard(
                          title: data['title'] ?? 'Internship',
                          company: data['companyName'] ?? 'Unknown Company',
                          location: data['location'] ?? 'Location not specified',
                          type: data['workplaceType'] ?? 'On-site',
                          duration: data['duration'] ?? 'Duration not specified',
                          logoUrl: data['logoUrl'],
                          onTap: () => context.push('/student/internship-detail', extra: jobDataForDetail),
                        ),
                      );
                    },
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

class _InternshipCard extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final String type;
  final String duration;
  final String? logoUrl;
  final VoidCallback onTap;

  const _InternshipCard({
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.duration,
    this.logoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    image: logoUrl != null 
                        ? DecorationImage(image: NetworkImage(logoUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: logoUrl == null
                      ? const Icon(Icons.business, color: AppColors.textSecondary, size: 20)
                      : null,
                ),
                const Icon(
                  Icons.bookmark_border,
                  color: AppColors.textSecondary,
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.paddingS),

            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            Text(
              '$company • $location',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: AppDimensions.paddingS),

            Row(
              children: [
                _Tag(label: type),
                const SizedBox(width: AppDimensions.paddingXS),
                _Tag(label: duration),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      ),
    );
  }
}