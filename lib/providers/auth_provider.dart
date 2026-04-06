import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  User? _user;
  String? _userType;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  String? get userType => _userType;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        _userType = await _authService.getUserType(user.uid);
      } else {
        _userType = null;
      }
      notifyListeners();
    });
  }

  // ─── JOBSEEKER SIGNUP ─────────────────────────────────
  Future<bool> signUpJobSeeker({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      await _authService.signUpJobSeeker(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      _setSuccess();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  // ─── COMPANY SIGNUP ───────────────────────────────────
  Future<bool> signUpCompany({
    required String companyName,
    required String category,
    required String email,
    required String password,
    required String licenseNumber,
  }) async {
    _setLoading();
    try {
      await _authService.signUpCompany(
        companyName: companyName,
        category: category,
        email: email,
        password: password,
        licenseNumber: licenseNumber,
      );
      _setSuccess();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  // ─── STUDENT SIGNUP ───────────────────────────────────
  Future<bool> signUpStudent({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      await _authService.signUpStudent(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      _setSuccess();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  // ─── LOGIN ────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      await _authService.login(email: email, password: password);
      _setSuccess();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  // ─── LOGOUT ───────────────────────────────────────────
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _userType = null;
    notifyListeners();
  }

  // ─── FORGOT PASSWORD ──────────────────────────────────
  Future<bool> resetPassword({required String email}) async {
    _setLoading();
    try {
      await _authService.resetPassword(email: email);
      _setSuccess();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  // ─── UPDATE PASSWORD ──────────────────────────────────
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading();
    try {
      await _authService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _setSuccess();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  // ─── HELPERS ──────────────────────────────────────────
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = AuthStatus.success;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  String _getErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'No internet connection. Please check your network.';
        default:
          return 'Something went wrong. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}