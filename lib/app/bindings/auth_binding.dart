import 'package:admin_my_store/app/controllers/auth_controller.dart';
import 'package:get/get.dart';


class AuthBinding implements Bindings {
  @override
  void dependencies() {
    // AuthRepository is now initialized in main.dart, so we only need the controller here.
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}