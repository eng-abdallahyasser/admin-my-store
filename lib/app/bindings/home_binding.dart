import 'package:admin_my_store/app/controllers/order_controller.dart';
import 'package:admin_my_store/app/repo/order_repository.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Register OrderRepository if it's not already available globally
    Get.lazyPut<OrderRepository>(() => OrderRepository());

    // Use fenix: true to make the controller persistent across the app session,
    // ensuring it's always listening for new orders.
    // Guard against double-registration: if another binding already registered
    // the controller (for example OrderBinding uses Get.put(..., permanent: true)),
    // don't register again.
    if (!Get.isRegistered<OrderController>()) {
      Get.lazyPut<OrderController>(() => OrderController(), fenix: true);
    }
  }
}
