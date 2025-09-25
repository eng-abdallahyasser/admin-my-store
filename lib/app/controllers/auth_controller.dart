import 'package:admin_my_store/app/models/app_user.dart';
import 'package:admin_my_store/app/repo/app_permissions.dart';
import 'package:admin_my_store/app/repo/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_my_store/app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final Rxn<User?> user = Rxn<User?>(null);
  final Rx<AppUser?> appUser = Rx<AppUser?>(null);
  final RxList<AppUser> users = RxList<AppUser>();
  AppUser? get currentUser => appUser.value;

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Keep controller in sync with Firebase auth state
    _authRepository.authStateChanges.listen((User? fbUser) async {
      user.value = fbUser;
      if (fbUser != null) {
        // Fetch role/permission data as soon as user logs in
        await initRoleData();
      } else {
        // Clear cached app user data on logout
        appUser.value = null;
      }
    });
  }

  void togglePasswordVisibility() {
    obscurePassword(!obscurePassword.value);
  }

  Future<void> login() async {
    try {
      isLoading(true);
      await _authRepository.signInWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      // Ensure roles are loaded before navigating to Home
      await initRoleData();
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Login Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> register() async {
    try {
      isLoading(true);
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Get.offAllNamed(Routes.home);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Registration Failed', e.message ?? 'Unknown error');
    } finally {
      isLoading(false);
    }
  }

  // Check if current user has permission
  bool hasPermission(String permission) {
    if (appUser.value == null) return false;
    return AppPermissions.can(permission, appUser.value!.roles);
  }

  // Check if current user has any of the required permissions
  bool hasAnyPermission(List<String> permissions) {
    if (appUser.value == null) return false;
    return permissions.any(
      (permission) => AppPermissions.can(permission, appUser.value!.roles),
    );
  }

  // User management methods (only for admins)
  Future<List<AppUser>> getUsers() async {
    if (!hasPermission('manage_users')) {
      throw Exception('Insufficient permissions');
    }
    isLoading.value = true;
    try {
      final result = await _authRepository.fetchAllUsers();
      users.value = result;
      return result;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserRoles(String userId, List<String> newRoles) async {
    if (!hasPermission('manage_users')) {
      throw Exception('Insufficient permissions');
    }

    await _authRepository.updateUserRoles(userId, newRoles);
  }

  // Check if email already exists
  Future<bool> checkEmailExists(String email) async {
    try {
      final methods = await _authRepository.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> forgotPassword() async {
    if (emailController.text.isEmail) {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      Get.snackbar('Success', 'Password reset email sent');
    } else {
      Get.snackbar('Error', 'Please enter a valid email');
    }
  }

  void checkUserLoggedIn() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is signed in, navigate to home
        Get.offAllNamed(Routes.home);
      }
    });
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back(); // Close the initial confirmation dialog
              Get.dialog(
                const AlertDialog(
                  title: Text('Logging out...'),
                  content: Center(child: CircularProgressIndicator()),
                ),
                barrierDismissible: false, // Prevent closing the loading dialog
              );
              await _authRepository.signOut();
              // Clear state
              appUser.value = null;
              user.value = null;
              Get.back(); // Close the loading dialog
              Get.offAllNamed(
                Routes.login,
                arguments: true,
              ); // Navigate to the splash screen
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close the confirmation dialog
            },
            child: const Text('No'),
          ),
        ],
      ),
    );
  }

  Future<void> initRoleData() async {
    isLoading.value = true;
    try {
      appUser.value = await _authRepository.getAppUserRoleData();
    } finally {
      isLoading.value = false;
    }
  }
}
