import 'package:admin_my_store/app/bindings/auth_binding.dart';
import 'package:get/get.dart';

class RoleManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthBinding());
  }
}


