import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String jobId;
  final String userId;
  final String userName;
  final String companyId;
  final String jobTitle;
  final String cvUrl;
  final String status;
  final String? additionalInfo;
  final DateTime? createdAt;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.userName,
    required this.companyId,
    required this.jobTitle,
    required this.cvUrl,
    this.status = 'pending',
    this.additionalInfo,
    this.createdAt,
  });

  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      companyId: data['companyId'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      cvUrl: data['cvUrl'] ?? '',
      status: data['status'] ?? 'pending',
      additionalInfo: data['additionalInfo'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'userId': userId,
      'userName': userName,
      'companyId': companyId,
      'jobTitle': jobTitle,
      'cvUrl': cvUrl,
      'status': status,
      'additionalInfo': additionalInfo,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}