import 'package:get/get.dart';

import '../controllers/banner_controller.dart';
import '../controllers/product_controller.dart';
import '../repo/banner_repository.dart';
import '../repo/product_repository.dart';

class BannerBinding implements Bindings {
  @override
  void dependencies() {
    // Product dependencies
    Get.lazyPut<ProductRepository>(() => ProductRepository(), fenix: true);
    Get.lazyPut<ProductController>(() => ProductController(), fenix: true);

    // Banner dependencies
    Get.lazyPut<BannerRepository>(() => BannerRepository(), fenix: true);
    Get.lazyPut<BannerController>(() => BannerController(), fenix: true);
  }
}
