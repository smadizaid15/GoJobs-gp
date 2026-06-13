import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> postJob({
    required String companyId,
    required String companyName,
    required String title,
    required String location,
    required String workplaceType,
    required String employmentType,
    required String description,
    String? salary,
    String? companyLogo, 
    List<String>? jobImages, // <-- NEW: Accepts the list of photo URLs
  }) async {
    try {
      await _firestore.collection('jobs').add({
        'companyId': companyId,
        'companyName': companyName,
        'title': title,
        'location': location,
        'workplaceType': workplaceType,
        'employmentType': employmentType,
        'description': description,
        'salary': salary, 
        'companyLogo': companyLogo, 
        'jobImages': jobImages ?? [], // <-- NEW: Saves them to Firebase
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to post job: $e');
    }
  }

  Stream<List<JobModel>> getActiveJobs() {
    return _firestore
        .collection('jobs')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return JobModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> toggleSavedJob(String userId, String jobId) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_jobs')
        .doc(jobId);
        
    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete(); 
    } else {
      await docRef.set({
        'jobId': jobId,
        'savedAt': FieldValue.serverTimestamp(),
      }); 
    }
  }

  Stream<List<String>> getSavedJobIds(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_jobs')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Stream<DocumentSnapshot> getLiveJobStream(String jobId) {
    return _firestore.collection('jobs').doc(jobId).snapshots();
    
  }
  // Get all jobs for a specific company
  Stream<List<JobModel>> getCompanyJobs(String companyId) {
    return _firestore
        .collection('jobs')
        .where('companyId', isEqualTo: companyId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return JobModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Delete a job from the database
  Future<void> deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
    } catch (e) {
      throw Exception('Failed to delete job: $e');
    }
  }
}