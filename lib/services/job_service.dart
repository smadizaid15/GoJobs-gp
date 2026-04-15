import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── POST A JOB ───────────────────────────────────────
  Future<void> postJob({
    required String companyId,
    required String companyName,
    required String title,
    required String location,
    required String workplaceType,
    required String employmentType,
    required String description,
  }) async {
    await _firestore.collection('jobs').add({
      'companyId': companyId,
      'companyName': companyName,
      'title': title,
      'location': location,
      'workplaceType': workplaceType,
      'employmentType': employmentType,
      'description': description,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── GET ALL ACTIVE JOBS ──────────────────────────────
  Stream<List<JobModel>> getActiveJobs() {
  return _firestore
      .collection('jobs')
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList());
}

  // ─── GET COMPANY JOBS ─────────────────────────────────
  Stream<List<JobModel>> getCompanyJobs(String companyId) {
    return _firestore
        .collection('jobs')
        .where('companyId', isEqualTo: companyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList());
  }

  // ─── DELETE JOB ───────────────────────────────────────
  Future<void> deleteJob(String jobId) async {
    await _firestore.collection('jobs').doc(jobId).update({
      'isActive': false,
    });
  }

  // ─── UPDATE JOB ───────────────────────────────────────
  Future<void> updateJob({
    required String jobId,
    required String title,
    required String location,
    required String workplaceType,
    required String employmentType,
    required String description,
  }) async {
    await _firestore.collection('jobs').doc(jobId).update({
      'title': title,
      'location': location,
      'workplaceType': workplaceType,
      'employmentType': employmentType,
      'description': description,
    });
  }

  // ─── SEARCH JOBS ──────────────────────────────────────
  Future<List<JobModel>> searchJobs(String query) async {
    final snapshot = await _firestore
        .collection('jobs')
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => JobModel.fromFirestore(doc))
        .where((job) =>
            job.title.toLowerCase().contains(query.toLowerCase()) ||
            job.location.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}