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

      if (credential.user != null) {
        return credential.user;
      }
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
      print('Error checking admin status: $e');
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
      return querySnapshot.docs
          .map((doc) => AppUser.fromMap(doc.id, doc.data()))
          .toList();
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
