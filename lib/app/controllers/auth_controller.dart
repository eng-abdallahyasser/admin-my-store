import 'package:admin_my_store/app/models/app_user.dart';
import 'package:admin_my_store/app/repo/app_permissions.dart';
import 'package:admin_my_store/app/repo/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_my_store/app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final Rxn<User> user = Rxn<User>();
  final Rx<AppUser?> appUser = Rx<AppUser?>(null);
  final RxList<AppUser> users = RxList<AppUser>();
  AppUser? get currentUser => appUser.value;

  final RxString error = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    initRoleData();
    // checkUserLoggedIn();
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

    return users.value = await _authRepository.fetchAllUsers();
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
  
  void initRoleData() async {
    isLoading.value = true;
    appUser.value = await _authRepository.getAppUserRoleData();
    isLoading.value = false;
  }
}
