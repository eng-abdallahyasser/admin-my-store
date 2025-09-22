import 'dart:developer';

import 'package:admin_my_store/app/bindings/auth_binding.dart';
import 'package:admin_my_store/app/repo/auth_repository.dart';
import 'package:admin_my_store/app/routes/app_pages.dart';
import 'package:admin_my_store/app/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:admin_my_store/firebase_options.dart';
import 'package:get/get.dart';



void main() async {
  try {
    log('main: App starting...');
    WidgetsFlutterBinding.ensureInitialized();
    log('main: WidgetsFlutterBinding initialized.');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log('main: Firebase initialized successfully.');

    // Initialize all core services AFTER Firebase is ready
    await initServices();
    log('main: Core services initialized.');

    runApp(MyApp());
    log('main: runApp() called.');
  } catch (e, s) {
    log('FATAL: App failed to start.', error: e, stackTrace: s);
  }
}

Future<void> initServices() async {
  log('initServices: Initializing core services...');
  // Repositories and other app-wide services
  Get.put<AuthRepository>(AuthRepository(), permanent: true);
  log('initServices: AuthRepository initialized.');
  // Add other permanent services here in the future
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialBinding: AuthBinding(),
      initialRoute: Routes.login,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}


void addOrdersForTest() async {
  final firestore = FirebaseFirestore.instance;

  try {
    // Test Order 1
    await firestore.collection('orders').add({
      'userId': 'user_001',
      'items': [
        {
          'productId': 'prod_001',
          'productTitle': 'Premium Headphones',
          'quantity': 1,
          'unitPrice': 299.99,
          'totalPrice': 299.99,
          'choosedVariant': [
            {
              'id': 'var_001',
              'name': 'Wireless',
              'price': 0.0, // Example variant
            }
          ],
        }
      ],
      'total': 299.99,
      'status': 'processing',
      'createdAt': FieldValue.serverTimestamp(),
      'paymentStatus': 'paid',
      'customerName': 'Alice Smith',
      'customerEmail': 'alice@example.com',
      'customerPhone': '+15551234567',
      'shippingAddress': '456 Oak Street, Tech City, TC 12345',
    });

    // Test Order 2
    await firestore.collection('orders').add({
      'userId': 'user_002',
      'items': [
        {
          'productId': 'prod_002',
          'productTitle': 'Wireless Mouse',
          'quantity': 2,
          'unitPrice': 49.99,
          'totalPrice': 99.98,
          'choosedVariant': [] // Empty variants
        },
        {
          'productId': 'prod_003',
          'productTitle': 'Keyboard',
          'quantity': 1,
          'unitPrice': 89.99,
          'totalPrice': 89.99,
          'choosedVariant': [
            {
              'id': 'var_002',
              'name': 'Mechanical',
              'price': 20.0,
            }
          ],
        }
      ],
      'total': 189.97,
      'status': 'shipped',
      'createdAt': Timestamp.fromDate(DateTime(2024, 3, 15)),
      'paymentStatus': 'paid',
      'customerName': 'Bob Johnson',
      'customerEmail': 'bob@example.com',
      'customerPhone': '+15559876543',
      'shippingAddress': '789 Pine Road, Gadget Town, GT 67890',
    });

    log('✅ Added test orders successfully!');
  } catch (e, stack) {
    log('❌ Error adding test orders: $e');
    log('Stack trace: $stack');
  }
}