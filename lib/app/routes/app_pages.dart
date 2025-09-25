import 'package:admin_my_store/app/bindings/category_binding.dart';
import 'package:admin_my_store/app/bindings/order_binding.dart';
import 'package:admin_my_store/app/bindings/order_detailes_binding.dart';
import 'package:admin_my_store/app/views/categories/add_category_screen.dart';
import 'package:admin_my_store/app/views/categories/category_list_screen.dart';
import 'package:admin_my_store/app/views/orders/order_details_screen.dart';
import 'package:admin_my_store/app/views/orders/order_list_screen.dart';
import 'package:admin_my_store/app/views/products/add_product_screen.dart';
import 'package:admin_my_store/app/views/products/edit_product_screen.dart';
import 'package:admin_my_store/app/views/roles/user_management_screen.dart';
import 'package:admin_my_store/app/views/status/status_screen.dart';

import 'package:get/get.dart';
import 'package:admin_my_store/app/bindings/home_binding.dart';
import 'package:admin_my_store/app/views/home/home_screen.dart';
import '../bindings/product_binding.dart';
import '../views/auth/login_screen.dart';
import '../views/products/product_list_screen.dart';
import 'app_routes.dart';
import 'package:admin_my_store/app/bindings/banner_binding.dart';
import 'package:admin_my_store/app/views/banners/banner_list_screen.dart';
import 'package:admin_my_store/app/views/banners/add_edit_banner_screen.dart';
import 'package:admin_my_store/app/bindings/feedback_binding.dart';
import 'package:admin_my_store/app/views/feedback/feedback_list_screen.dart';
import 'package:admin_my_store/app/bindings/notifications_binding.dart';
import 'package:admin_my_store/app/views/notifications/notifications_screen.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => LoginScreen(),
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
    GetPage(
      name: Routes.orders,
      page: () => OrderListScreen(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: Routes.orderDetails,
      page: () => OrderDetailsScreen(),
      binding: OrderDetailsBinding(),
    ),
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
    GetPage(name: Routes.status, page: () => RestaurantStatusScreen()),
    GetPage(
      name: Routes.userManagement,
      page: () => UserManagementScreen(),
    ),
    // Banners
    GetPage(
      name: Routes.banners,
      page: () => BannerListScreen(),
      binding: BannerBinding(),
    ),
    GetPage(
      name: Routes.addBanner,
      page: () => AddEditBannerScreen(),
      binding: BannerBinding(),
    ),
    GetPage(
      name: Routes.editBanner,
      page: () => AddEditBannerScreen(),
      binding: BannerBinding(),
    ),
    // Feedback
    GetPage(
      name: Routes.feedback,
      page: () => FeedbackListScreen(),
      binding: FeedbackBinding(),
    ),
    GetPage(
      name: Routes.notifications,
      page: () => NotificationsScreen(),
      binding: NotificationsBinding(),
    ),
    // GetPage(
    //   name: Routes.customers,
    //   page: () => CustomerListScreen(),
    // ),
  ];
}
