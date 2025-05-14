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
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 500,
              ),
              padding: EdgeInsets.all(isMobile ? 20.0 : 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isMobile) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/logo.jpg',
                        height: 100,
                        width: 100,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                  Text(
                    'Wesaya Dashboard',
                    style: TextStyle(
                      fontSize: isMobile ? 22.0 : 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildLoginForm(isMobile, isLargeScreen),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool isMobile, bool isLargeScreen) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _authController.emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email),
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                vertical: isMobile ? 14.0 : 16.0,
                horizontal: 16.0,
              ),
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
                onPressed: _authController.togglePasswordVisibility,
              ),
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                vertical: isMobile ? 14.0 : 16.0,
                horizontal: 16.0,
              ),
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
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _authController.forgotPassword,
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 20),
          Obx(() => CustomButton(
            text: 'Login',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _authController.login();
              }
            },
            isLoading: _authController.isLoading.value,
          )),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?"),
              TextButton(
                onPressed: () => Get.toNamed(Routes.register),
                child: const Text('Sign up'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}