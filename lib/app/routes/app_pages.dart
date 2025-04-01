import 'package:admin_my_store/app/bindings/auth_binding.dart';
import 'package:admin_my_store/app/bindings/category_binding.dart';
import 'package:admin_my_store/app/views/categories/add_category_screen.dart';
import 'package:admin_my_store/app/views/categories/category_list_screen.dart';
import 'package:admin_my_store/app/views/products/add_product_screen.dart';
import 'package:admin_my_store/app/views/products/edit_product_screen.dart';
import 'package:get/get.dart';
import 'package:admin_my_store/app/views/home/home_screen.dart';
import '../bindings/product_binding.dart';
import '../views/auth/login_screen.dart';
import '../views/products/product_list_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: Routes.home, page: () => const HomeScreen()),
    GetPage(
      name: Routes.login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.products,
      page: () => ProductListScreen(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: Routes.addProduct,
      page: () => AddProductScreen(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: Routes.editProduct,
      page: () => EditProductScreen(),
      binding: ProductBinding(),
    ),
    // GetPage(
    //   name: Routes.orders,
    //   page: () => OrderListScreen(),
    //   // binding: OrderBinding(),
    // ),
    GetPage(
      name: Routes.categories,
      page: () => CategoryListScreen(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: Routes.addCategory,
      page: () => AddCategoryScreen(),
      binding: CategoryBinding(),
    ),
    // GetPage(
    //   name: Routes.customers,
    //   page: () => CustomerListScreen(),
    // ),
  ];
}
