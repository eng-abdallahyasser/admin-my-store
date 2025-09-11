import 'package:get/get.dart';

import '../controllers/banner_controller.dart';
import '../repo/banner_repository.dart';

class BannerBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BannerRepository>(() => BannerRepository(), fenix: true);
    Get.lazyPut<BannerController>(() => BannerController(), fenix: true);
  }
}
