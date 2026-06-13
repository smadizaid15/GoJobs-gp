import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';     
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';        
import 'dart:typed_data';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class CompanyAddJobScreen extends StatefulWidget {
  const CompanyAddJobScreen({super.key});

  @override
  State<CompanyAddJobScreen> createState() => _CompanyAddJobScreenState();
}

class _CompanyAddJobScreenState extends State<CompanyAddJobScreen> {
  String? _jobCategory; // 'Job', 'Internship', or 'Course'
  String? _jobPosition;
  String? _workplaceType;
  String? _jobLocation;
  String? _employmentType;
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController(); 
  bool _isPosting = false;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  @override
  void dispose() {
    _descriptionController.dispose();
    _salaryController.dispose(); 
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Sleek bottom sheet to pick category without needing a new route
  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusL)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: ['Job', 'Internship', 'Course'].map((String cat) {
              return ListTile(
                title: Text(cat, style: AppTextStyles.bodyMedium),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  setState(() => _jobCategory = cat);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      }
    );
  }

  Future<void> _handlePostJob() async {
    if (_jobCategory == null ||
        _jobPosition == null ||
        _workplaceType == null ||
        _jobLocation == null ||
        _employmentType == null ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // 1. Fetch Company details
      String realCompanyName = 'Unknown Company';
      String? realCompanyLogo; 
      
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
      if (userDoc.exists && userDoc.data() != null) {
        realCompanyName = userDoc.data()!['companyName']?.toString() ?? 'Unknown Company';
        realCompanyLogo = userDoc.data()!['logoUrl']?.toString(); 
      }

      // 2. Upload images to Firebase Storage
      List<String> uploadedImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        for (var image in _selectedImages) {
          final bytes = await image.readAsBytes();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
          final ref = FirebaseStorage.instance.ref().child('job_images/$currentUserId/$fileName');
          
          final uploadTask = await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
          final url = await uploadTask.ref.getDownloadURL();
          uploadedImageUrls.add(url);
        }
      }

      // 3. Post the job directly to Firestore to guarantee schema
      await FirebaseFirestore.instance.collection('jobs').add({
        'companyId': currentUserId,
        'companyName': realCompanyName,
        'logoUrl': realCompanyLogo,
        'jobType': _jobCategory, // "Job", "Internship", or "Course"
        'title': _jobPosition,
        'location': _jobLocation,
        'workplaceType': _workplaceType,
        'employmentType': _employmentType,
        'description': _descriptionController.text.trim(),
        'salary': _salaryController.text.trim().isEmpty ? null : _salaryController.text.trim(),
        'jobImages': uploadedImageUrls,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. Send Notification
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': currentUserId, // Changed to userId for consistency
        'type': 'job',
        'title': '$_jobCategory Posted',
        'message': 'Your $_jobPosition post is now live.',
        'actionLabel': 'View Jobs',
        'actionRoute': '/company/jobs', 
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/company/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.close, color: AppColors.textPrimary),
                  ),
                  Text(
                    'Create Post',
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _isPosting ? null : _handlePostJob,
                    child: _isPosting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.companyGold,
                            ),
                          )
                        : Text(
                            'Post',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.companyGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                child: Column(
                  children: [
                    _JobFormItem(
                      label: 'Post Category*',
                      value: _jobCategory,
                      onTap: _showCategoryPicker,
                    ),

                    _JobFormItem(
                      label: 'Job position*',
                      value: _jobPosition,
                      onTap: () async {
                        final result = await context.push<String>('/company/job-position-picker');
                        if (result != null) setState(() => _jobPosition = result);
                      },
                    ),

                    _JobFormItem(
                      label: 'Type of workplace*',
                      value: _workplaceType,
                      onTap: () async {
                        final result = await context.push<String>('/company/workplace-type');
                        if (result != null) setState(() => _workplaceType = result);
                      },
                    ),

                    _JobFormItem(
                      label: 'Job location*',
                      value: _jobLocation,
                      onTap: () async {
                        final result = await context.push<String>('/company/location-picker');
                        if (result != null) setState(() => _jobLocation = result);
                      },
                    ),

                    _JobFormItem(
                      label: 'Employment type*',
                      value: _employmentType,
                      onTap: () async {
                        final result = await context.push<String>('/company/job-type');
                        if (result != null) setState(() => _employmentType = result);
                      },
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Salary (Optional)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: TextField(
                        controller: _salaryController,
                        decoration: InputDecoration(
                          hintText: 'e.g. 500 JOD / month',
                          hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Workplace Photos',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.add_a_photo, color: AppColors.companyGold, size: 16),
                            label: Text('Add Photos', style: AppTextStyles.bodySmall.copyWith(color: AppColors.companyGold)),
                          )
                        ],
                      ),
                    ),
                    if (_selectedImages.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.paddingS),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return FutureBuilder<Uint8List>(
                              future: _selectedImages[index].readAsBytes(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox(
                                    width: 100, 
                                    child: Center(child: CircularProgressIndicator())
                                  );
                                }
                                return Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      margin: const EdgeInsets.only(right: AppDimensions.paddingS),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                        image: DecorationImage(
                                          image: MemoryImage(snapshot.data!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 12,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: AppDimensions.paddingL),

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => context.push('/ai-job-description'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: AppDimensions.paddingXS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.companyGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            border: Border.all(
                              color: AppColors.companyGold.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.smart_toy_outlined, color: AppColors.companyGold, size: 14),
                              const SizedBox(width: AppDimensions.paddingXS),
                              Text(
                                'Generate with AI',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.companyGold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXS),
                    
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Description*',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Container(
                      height: 120,
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Write job description here...',
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),

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

class _JobFormItem extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _JobFormItem({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingM,
          horizontal: AppDimensions.paddingS,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (value != null)
                  Text(
                    value!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const Icon(
              Icons.add,
              color: AppColors.companyGold,
            ),
          ],
        ),
      ),
    );
  }
}