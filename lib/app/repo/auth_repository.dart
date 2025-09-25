import 'dart:developer';

import 'package:admin_my_store/app/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      bool isAdmin = await checkIfUserIsAdmin(email);
      if (!isAdmin) {
        throw FirebaseAuthException(
          code: 'not-admin',
          message: 'You do not have permission to access the admin panel.',
        );
      }
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // log(credential.toString(), name: 'AuthRepository');

      if (credential.user != null) {
        return credential.user;
      }

      log( credential.user!.getIdToken(true).toString());
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Authentication failed');
    }
  }

  Future<bool> checkIfUserIsAdmin(String email) async {
    try {
      // Query Firestore to check if user email in "admins" collection
      DocumentSnapshot adminDoc =
          await _firestore.collection('admins').doc("admins").get();

      // Return true if the email exists in the admin collection
      if (adminDoc.exists) {
        List<String> adminEmails = List<String>.from(adminDoc['emails']);
        return adminEmails.contains(email);
      }
      return false;
    } catch (e) {
      log('Error checking admin status: $e');
      return false;
    }
  }

  Future<User?> createUserWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<User?> userData() async {
    return _firebaseAuth.currentUser;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> updateUserRoles(String userId, List<String> newRoles) async {
    try {
      await _firestore.collection('admins').doc(userId).update({
        'roles': newRoles,
      });
    } catch (e) {
      throw Exception('Failed to update user roles: $e');
    }
  }

  Future<List<AppUser>> fetchAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('admins').get();
      List<AppUser> users = [];

      for (var doc in querySnapshot.docs) {
        // Skip the admin configuration document
        if (doc.id == 'admins') {
          continue;
        }

        Map<String, dynamic> data = doc.data();

        // If email is not in the document, try to find it in admin emails
        // This is a fallback - ideally email should be stored in each user doc
        if (data['email'] == null || data['email'].toString().isEmpty) {
          // For now, we'll use a placeholder or try to get from document ID if it's an email
          if (doc.id.contains('@')) {
            data['email'] = doc.id;
          } else {
            data['email'] = 'email-not-found@example.com';
          }
        }

        // If displayName is empty, use email as fallback
        if (data['displayName'] == null ||
            data['displayName'].toString().isEmpty) {
          data['displayName'] = data['email'].toString().split('@')[0];
        }

        users.add(AppUser.fromMap(doc.id, data));
      }

      return users;
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<AppUser?> getAppUserRoleData() async {
    try {
      final userDoc =
          await _firestore.collection('admins').doc(currentUser?.uid).get();
      if (userDoc.exists) {
        return AppUser.fromMap(currentUser!.uid, userDoc.data()!);
      } else {
        // Create new user document if it doesn't exist
        return null;
      }
    } catch (e) {
      throw Exception('Failed to fetch user role data: $e');
    }
  }

  Future fetchSignInMethodsForEmail(String email) async {
    try {
      return await _firebaseAuth.fetchSignInMethodsForEmail(email);
    } catch (e) {
      throw Exception('Failed to fetch sign-in methods: $e');
    }
  }
}
