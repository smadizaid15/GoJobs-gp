import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart'; 

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class JobseekerResumeScreen extends StatefulWidget {
  const JobseekerResumeScreen({super.key});

  @override
  State<JobseekerResumeScreen> createState() => _JobseekerResumeScreenState();
}

class _JobseekerResumeScreenState extends State<JobseekerResumeScreen> {
  Uint8List? _resumeBytes;
  String? _resumeName;
  int? _resumeSizeInKb;
  
  bool _isSaving = false;
  bool _isLoading = true; 
  
  String? _existingResumeUrl;
  DateTime? _existingResumeDate;

  @override
  void initState() {
    super.initState();
    _fetchExistingResume(); 
  }

  Future<void> _fetchExistingResume() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
        
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          // Safety check: if they have a URL, they have a resume
          if (data['hasResume'] == true || data['resumeUrl'] != null) {
            setState(() {
              _resumeName = data['resumeName']?.toString();
              _existingResumeUrl = data['resumeUrl']?.toString();
              if (data['resumeLastUpdated'] != null) {
                _existingResumeDate = (data['resumeLastUpdated'] as Timestamp).toDate();
              }
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching existing resume: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickResume() async {
    try {
      fp.FilePickerResult? result = await fp.FilePicker.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true, 
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _resumeBytes = result.files.single.bytes;
          _resumeName = result.files.single.name;
          _resumeSizeInKb = (result.files.single.size / 1024).round();
        });
      }
    } catch (e) {
      print("Error picking resume: $e");
    }
  }

  Future<void> _saveResumeToProfile() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    // SCENARIO 0: They didn't change anything, just exit
    if (_resumeBytes == null && _resumeName != null && _existingResumeUrl != null) {
      context.go('/jobseeker/profile');
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_resumeBytes != null) {
        // SCENARIO 1: Uploading a NEW file
        final String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$_resumeName';
        final storageRef = FirebaseStorage.instance.ref().child('user_resumes/$currentUserId/$uniqueFileName');

        final uploadTask = await storageRef.putData(_resumeBytes!);
        final secureFileUrl = await uploadTask.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(currentUserId).set({
          'resumeName': _resumeName,
          'resumeUrl': secureFileUrl,
          'resumeLastUpdated': FieldValue.serverTimestamp(),
          'hasResume': true,
        }, SetOptions(merge: true));

      } else if (_resumeName == null) {
        // SCENARIO 2: They hit the trash can and want to DELETE the file
        
        // Step 1: Actually delete the physical file from Firebase Storage so it doesn't take up space
        if (_existingResumeUrl != null) {
          try {
            await FirebaseStorage.instance.refFromURL(_existingResumeUrl!).delete();
          } catch(e) {
            print("Notice: Could not delete old file from storage (might already be deleted): $e");
          }
        }

        // Step 2: Bulletproof deletion from Firestore using SetOptions(merge: true) instead of update()
        await FirebaseFirestore.instance.collection('users').doc(currentUserId).set({
          'hasResume': false,
          'resumeName': FieldValue.delete(),
          'resumeUrl': FieldValue.delete(),
          'resumeLastUpdated': FieldValue.delete(),
        }, SetOptions(merge: true));

        _existingResumeUrl = null; // Clear local reference
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume profile updated!'), backgroundColor: Colors.green),
        );
        context.go('/jobseeker/profile');
      }
    } catch (e) {
      print('Critical error saving resume: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateToShow = '';
    if (_resumeBytes != null) {
      dateToShow = DateFormat('dd MMM yyyy').format(DateTime.now());
    } else if (_existingResumeDate != null) {
      dateToShow = DateFormat('dd MMM yyyy').format(_existingResumeDate!);
    }

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
                onTap: () => context.go('/jobseeker/profile'),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              Text(
                'Add Resume',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Upload Box
              GestureDetector(
                onTap: _pickResume, 
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.paddingXL),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(
                      color: AppColors.divider,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.upload_outlined,
                        color: AppColors.textSecondary,
                        size: 40,
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      Text(
                        'Upload CV/Resume',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingXS),
                      Text(
                        'Upload files in PDF format up to 5 MB. Just upload it once and you can use it in your next application.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_resumeName != null)
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.purpleButton,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(color: AppColors.purpleButtonBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                        size: 32,
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _resumeName!, 
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _resumeBytes != null 
                                ? '${_resumeSizeInKb ?? 0} Kb • $dateToShow'
                                : 'Saved Document • $dateToShow', 
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          _resumeBytes = null;
                          _resumeName = null;
                          _resumeSizeInKb = null;
                        }),
                        child: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveResumeToProfile,
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
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