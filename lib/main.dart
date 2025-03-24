import 'package:admin_my_store/app/bindings/auth_binding.dart';
import 'package:admin_my_store/app/routes/app_pages.dart';
import 'package:admin_my_store/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
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