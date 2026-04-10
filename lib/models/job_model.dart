import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String companyId;
  final String companyName;
  final String title;
  final String location;
  final String workplaceType;
  final String employmentType;
  final String description;
  final bool isActive;
  final DateTime? createdAt;

  JobModel({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.title,
    required this.location,
    required this.workplaceType,
    required this.employmentType,
    required this.description,
    this.isActive = true,
    this.createdAt,
  });

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobModel(
      id: doc.id,
      companyId: data['companyId'] ?? '',
      companyName: data['companyName'] ?? '',
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      workplaceType: data['workplaceType'] ?? '',
      employmentType: data['employmentType'] ?? '',
      description: data['description'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'companyName': companyName,
      'title': title,
      'location': location,
      'workplaceType': workplaceType,
      'employmentType': employmentType,
      'description': description,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}