import 'package:get/get.dart';
import 'package:admin_my_store/app/controllers/notifications_controller.dart';

class NotificationsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationsController());
  }
}
