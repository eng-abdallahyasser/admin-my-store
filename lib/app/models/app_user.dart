import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String uid;
  String email;
  String displayName;
  List<String> roles;
  DateTime createdAt;
  bool isActive;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.roles,
    required this.createdAt,
    required this.isActive,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      roles: List<String>.from(data['roles'] ?? ['viewer']),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'roles': roles,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  bool hasRole(String role) => roles.contains(role);
  
  bool hasAnyRole(List<String> requiredRoles) {
    return roles.any((role) => requiredRoles.contains(role));
  }

  bool get isSuperAdmin => hasRole('super_admin');
  bool get isAdmin => hasRole('admin') || isSuperAdmin;
  bool get isManager => hasRole('manager') || isAdmin;
  bool get isEditor => hasRole('editor') || isManager;
  bool get isViewer => hasRole('viewer') || isEditor;
}