// login_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_my_store/app/controllers/auth_controller.dart';
import 'package:admin_my_store/app/routes/app_routes.dart';
import 'package:admin_my_store/app/widgets/custom_button.dart';

class LoginScreen extends StatelessWidget {
  final AuthController _authController = Get.find();
  
  final _formKey = GlobalKey<FormState>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 100),
                const FlutterLogo(size: 100),
                const SizedBox(height: 40),
                const Text(
                  'Admin Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _authController.emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.isEmail) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Obx(() => TextFormField(
                  controller: _authController.passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_authController.obscurePassword.value
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: (){},
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: _authController.obscurePassword.value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                )),
                const SizedBox(height: 20),
                Obx(() => CustomButton(
                  text: 'Login',
                  onPressed: (){
                    if (_formKey.currentState!.validate()) {
                      _authController.login();
                    }
                  },
                  isLoading: _authController.isLoading.value,
                )),
                TextButton(
                  onPressed: () => Get.toNamed(Routes.register),
                  child: const Text('Create new account'),
                ),
                TextButton(
                  onPressed: _authController.forgotPassword,
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}