import 'package:admin_my_store/app/controllers/category_controller.dart';
import 'package:admin_my_store/app/repo/category_repository.dart';
import 'package:get/get.dart';


class CategoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryRepository>(() => CategoryRepository());
    Get.lazyPut<CategoryController>(() => CategoryController());
  }
}