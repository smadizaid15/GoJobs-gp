import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';

class ApplicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> applyForJob({
    required String jobId,
    required String userId,
    required String userName,
    required String companyId,
    required String jobTitle,
    required String cvUrl,
    String? additionalInfo,
  }) async {
    // Check if applied before
    final existing = await _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .where('userId', isEqualTo: userId)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('You have already applied for this job');
    }

    await _firestore.collection('applications').add({
      'jobId': jobId,
      'userId': userId,
      'userName': userName,
      'companyId': companyId,
      'jobTitle': jobTitle,
      'cvUrl': cvUrl,
      'additionalInfo': additionalInfo,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ApplicationModel>> getUserApplications(String userId) {
    return _firestore
        .collection('applications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplicationModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<ApplicationModel>> getJobApplications(String jobId) {
    return _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplicationModel.fromFirestore(doc))
            .toList());
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    await _firestore
        .collection('applications')
        .doc(applicationId)
        .update({'status': status});
  }
}