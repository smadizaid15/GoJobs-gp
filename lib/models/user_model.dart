import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String userType;
  final String? firstName;
  final String? lastName;
  final String? companyName;
  final String? category;
  final String? licenseNumber;
  final String? userMode;
  final String? profilePicUrl;
  final String? location;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.userType,
    this.firstName,
    this.lastName,
    this.companyName,
    this.category,
    this.licenseNumber,
    this.userMode,
    this.profilePicUrl,
    this.location,
    this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      userType: data['userType'] ?? '',
      firstName: data['firstName'],
      lastName: data['lastName'],
      companyName: data['companyName'],
      category: data['category'],
      licenseNumber: data['licenseNumber'],
      userMode: data['userMode'],
      profilePicUrl: data['profilePicUrl'],
      location: data['location'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'userType': userType,
      'firstName': firstName,
      'lastName': lastName,
      'companyName': companyName,
      'category': category,
      'licenseNumber': licenseNumber,
      'userMode': userMode,
      'profilePicUrl': profilePicUrl,
      'location': location,
      'createdAt': createdAt,
    };
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  String get displayName => companyName ?? fullName;
}