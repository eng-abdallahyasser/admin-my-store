import 'package:admin_my_store/app/controllers/auth_controller.dart';
import 'package:admin_my_store/app/repo/auth_repository.dart';
import 'package:get/get.dart';


class AuthBinding implements Bindings {
  @override
  void dependencies() {
    // Initialize AuthRepository
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
    
    // Initialize AuthController
    Get.lazyPut<AuthController>(
      () => AuthController(),
      fenix: true,
    );
  }
}