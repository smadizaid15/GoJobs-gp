import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../widgets/jobseeker_bottom_nav.dart';
import '../../../services/job_service.dart';
import '../../../models/job_model.dart';

class JobseekerSearchScreen extends StatefulWidget {
  final String? initialFilter; 

  const JobseekerSearchScreen({super.key, this.initialFilter});

  @override
  State<JobseekerSearchScreen> createState() => _JobseekerSearchScreenState();
}

class _JobseekerSearchScreenState extends State<JobseekerSearchScreen> {
  final _searchController = TextEditingController();
  final _locationController = TextEditingController();
  final _jobService = JobService();

  String _currentFilter = '';
  Map<String, dynamic>? _appliedFilters;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter ?? '';
    
    _searchController.addListener(() => setState(() {}));
    _locationController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: Column(
          children: [
          
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: const BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppDimensions.radiusXL),
                  bottomRight: Radius.circular(AppDimensions.radiusXL),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/jobseeker/home'),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Text(
                        _currentFilter == 'Internships' ? 'Find Internships' : 'Find Your Job',
                        style: AppTextStyles.heading3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textSecondary),
                        const SizedBox(width: AppDimensions.paddingS),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search title or company',
                              hintStyle: AppTextStyles.bodySmall,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingS),

                 
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.primaryOrange),
                        const SizedBox(width: AppDimensions.paddingS),
                        Expanded(
                          child: TextField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              hintText: 'Location (e.g. Irbid)',
                              hintStyle: AppTextStyles.bodySmall,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final result = await context.push('/jobseeker/filter');
                            if (result != null && result is Map<String, dynamic>) {
                              setState(() {
                                _appliedFilters = result;
                                if (result['location'] != null && result['location'] != 'Remote') {
                                  _locationController.text = result['location'];
                                }
                              });
                            }
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                            ),
                            child: const Icon(Icons.tune, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingM),

            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _currentFilter = ''),
                    child: _FilterChip(label: 'All', isSelected: _currentFilter == ''),
                  ),
                  const SizedBox(width: AppDimensions.paddingS),
                  GestureDetector(
                    onTap: () => setState(() => _currentFilter = 'Jobs'),
                    child: _FilterChip(label: 'Jobs', isSelected: _currentFilter == 'Jobs'),
                  ),
                  const SizedBox(width: AppDimensions.paddingS),
                  GestureDetector(
                    onTap: () => setState(() => _currentFilter = 'Internships'),
                    child: _FilterChip(label: 'Internships', isSelected: _currentFilter == 'Internships'),
                  ),
                  
                  if (_appliedFilters != null) ...[
                    const SizedBox(width: AppDimensions.paddingS),
                    GestureDetector(
                      onTap: () => setState(() {
                        _appliedFilters = null;
                        _locationController.clear();
                      }),
                      child: _FilterChip(label: 'Clear Advanced Filters ✕', isSelected: true),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingM),

           
            Expanded(
              child: StreamBuilder<List<JobModel>>(
                stream: _jobService.getActiveJobs(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final allJobs = snapshot.data ?? [];

                  final filteredJobs = allJobs.where((job) {
                    final searchMatch = job.title.toLowerCase().contains(_searchController.text.toLowerCase()) || 
                                        job.companyName.toLowerCase().contains(_searchController.text.toLowerCase());
                    
                    final locMatch = job.location.toLowerCase().contains(_locationController.text.toLowerCase());
                    
                    bool typeMatch = true;
                    if (_currentFilter == 'Internships') {
                      typeMatch = job.employmentType.toLowerCase().contains('internship');
                    } else if (_currentFilter == 'Jobs') {
                      typeMatch = !job.employmentType.toLowerCase().contains('internship');
                    }

                    bool advancedMatch = true;
                    if (_appliedFilters != null) {
                      if (_appliedFilters!['jobType'] != null && _appliedFilters!['jobType'] != '') {
                        if (job.employmentType.toLowerCase() != _appliedFilters!['jobType'].toString().toLowerCase()) {
                          advancedMatch = false;
                        }
                      }
                      
                      if (_appliedFilters!['category'] != null) {
                        final cat = _appliedFilters!['category'].toString().toLowerCase();
                        if (!job.title.toLowerCase().contains(cat) && !job.description.toLowerCase().contains(cat)) {
                          advancedMatch = false;
                        }
                      }
                    }

                    return searchMatch && locMatch && typeMatch && advancedMatch;
                  }).toList();

                  if (filteredJobs.isEmpty) {
                    return Center(
                      child: Text(
                        'No results found',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                        child: _SearchJobCard(
                          title: job.title,
                          company: job.companyName,
                          location: job.location,
                          tags: [job.employmentType, job.workplaceType],
                          salary: 'View Details',
                          onTap: () => context.push('/jobseeker/job-detail', extra: {
                            'id': job.id,
                            'title': job.title,
                            'companyName': job.companyName,
                            'location': job.location,
                            'workplaceType': job.workplaceType,
                            'employmentType': job.employmentType,
                            'description': job.description,
                          }),
                          onSave: () async {
                            final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
                            await _jobService.toggleSavedJob(currentUserId, job.id);
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${job.title} saved to profile!'),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const JobseekerBottomNav(currentIndex: 2),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: AppDimensions.paddingXS),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryNavy : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

class _SearchJobCard extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final List<String> tags;
  final String salary;
  final VoidCallback onTap;
  final VoidCallback onSave;

  const _SearchJobCard({
    required this.title,
    required this.company,
    required this.location,
    required this.tags,
    required this.salary,
    required this.onTap,
    required this.onSave,
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
                  ),
                  child: const Icon(Icons.business, color: AppColors.textSecondary, size: 20),
                ),
                GestureDetector(
                  onTap: onSave,
                  child: const Icon(Icons.bookmark_border, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            Text(
              '$company • $location',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Wrap(
              spacing: AppDimensions.paddingXS,
              children: tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingS, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    tag,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 10),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}