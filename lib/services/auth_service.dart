import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signUpJobSeeker({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'userType': 'jobSeeker',
        'userMode': 'jobSeeker',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await credential.user!.sendEmailVerification();
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signUpCompany({
    required String companyName,
    required String category,
    required String email,
    required String password,
    required String licenseNumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'companyName': companyName,
        'category': category,
        'email': email,
        'licenseNumber': licenseNumber,
        'userType': 'company',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await credential.user!.sendEmailVerification();
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signUpStudent({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'userType': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await credential.user!.sendEmailVerification();
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<String?> getUserType(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['userType'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser!;
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    }
  }
}