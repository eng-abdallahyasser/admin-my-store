import 'package:admin_my_store/app/repo/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_my_store/app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find();
  final Rxn<User> user = Rxn<User>();
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkUserLoggedIn();
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
}
