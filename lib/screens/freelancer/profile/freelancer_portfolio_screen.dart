import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class FreelancerPortfolioScreen extends StatefulWidget {
  const FreelancerPortfolioScreen({super.key});

  @override
  State<FreelancerPortfolioScreen> createState() =>
      _FreelancerPortfolioScreenState();
}

class _FreelancerPortfolioScreenState extends State<FreelancerPortfolioScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  List<String> _existingImages = [];
  final List<XFile> _newSelectedImages = [];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data['portfolioImages'] != null) {
            setState(() {
              _existingImages = List<String>.from(data['portfolioImages']);
            });
          }
        }
      } catch (e) {
        debugPrint("Error loading portfolio: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
    if (images.isNotEmpty) {
      setState(() {
        _newSelectedImages.addAll(images);
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newSelectedImages.removeAt(index);
    });
  }

  Future<void> _removeExistingImage(String imageUrl) async {
    setState(() {
      _existingImages.remove(imageUrl);
    });

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'portfolioImages': _existingImages,
      });
    }
  }

  Future<void> _savePortfolio() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      List<String> uploadedUrls = [];

      for (var image in _newSelectedImages) {
        final bytes = await image.readAsBytes();
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final ref = FirebaseStorage.instance.ref().child(
          'portfolio_images/${user.uid}/$fileName',
        );

        final uploadTask = await ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final url = await uploadTask.ref.getDownloadURL();
        uploadedUrls.add(url);
      }

      final finalImagesList = [..._existingImages, ...uploadedUrls];

      await _firestore.collection('users').doc(user.uid).update({
        'portfolioImages': finalImagesList,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Portfolio updated!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/freelancer/profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save portfolio: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAnyPhotos =
        _existingImages.isNotEmpty || _newSelectedImages.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Portfolio Photos',
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(
                            Icons.add_a_photo,
                            color: AppColors.primaryNavy,
                            size: 18,
                          ),
                          label: Text(
                            'Add',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryNavy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),

                    if (!hasAnyPhotos) ...[
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusL,
                            ),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.upload_outlined,
                                color: AppColors.textSecondary,
                                size: 40,
                              ),
                              const SizedBox(height: AppDimensions.paddingS),
                              Text(
                                'Tap to select photos',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: AppDimensions.paddingM,
                                mainAxisSpacing: AppDimensions.paddingM,
                              ),
                          itemCount:
                              _existingImages.length +
                              _newSelectedImages.length,
                          itemBuilder: (context, index) {
                            if (index < _existingImages.length) {
                              final imageUrl = _existingImages[index];
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusM,
                                    ),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _removeExistingImage(imageUrl),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            final newImageIndex =
                                index - _existingImages.length;
                            return FutureBuilder<Uint8List>(
                              future: _newSelectedImages[newImageIndex]
                                  .readAsBytes(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData)
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusM,
                                      ),
                                      child: Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () =>
                                            _removeNewImage(newImageIndex),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: AppDimensions.paddingL),

                    if (hasAnyPhotos)
                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _savePortfolio,
                          child: _isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'SAVE CHANGES',
                                  style: AppTextStyles.buttonText,
                                ),
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
