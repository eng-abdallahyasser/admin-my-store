import 'package:admin_my_store/app/controllers/orde_detailes_controller.dart';
import 'package:admin_my_store/app/repo/order_repository.dart';
import 'package:admin_my_store/app/repo/product_repository.dart';
import 'package:get/get.dart';


class OrderDetailsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrderRepository());
    Get.lazyPut(() => OrderDetailsController());
    Get.lazyPut( () => ProductRepository());
  }
}