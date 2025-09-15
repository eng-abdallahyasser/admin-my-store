import 'package:admin_my_store/app/controllers/auth_controller.dart';
import 'package:admin_my_store/app/repo/auth_repository.dart';
import 'package:get/get.dart';


class AuthBinding implements Bindings {
  @override
  void dependencies() {
    // Initialize AuthRepository as a permanent dependency
    Get.put<AuthRepository>(AuthRepository(), permanent: true);

    // Initialize AuthController as a permanent dependency
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}