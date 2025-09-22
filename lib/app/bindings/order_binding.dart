import 'package:admin_my_store/app/controllers/order_controller.dart';
import 'package:admin_my_store/app/repo/order_repository.dart';
import 'package:get/get.dart';


class OrderBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderRepository>(() => OrderRepository());
    // Make OrderController persistent to preserve filter state across navigation
    Get.put<OrderController>(OrderController(), permanent: true);
  }
}