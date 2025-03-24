import 'package:get/get.dart';

import '../controllers/product_controller.dart';
import '../repo/product_repository.dart';

class ProductBinding implements Bindings {
  @override
  void dependencies() {
    // Initialize Product Repository
    Get.lazyPut<ProductRepository>(
          () => ProductRepository(),
      fenix: true,
    );

    // Initialize Product Controller
    Get.lazyPut<ProductController>(
          () => ProductController(),
      fenix: true,
    );
  }
}