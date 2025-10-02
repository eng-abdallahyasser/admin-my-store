import 'dart:developer';

import 'package:admin_my_store/app/bindings/auth_binding.dart';
import 'package:admin_my_store/app/repo/auth_repository.dart';
import 'package:admin_my_store/app/repo/notification_repository.dart';
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
  Get.put<NotificationRepository>(NotificationRepository(), permanent: true);
  log('initServices: NotificationRepository initialized.');
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