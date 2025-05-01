import 'package:admin_my_store/app/models/my_order.dart';
import 'package:admin_my_store/app/models/product.dart';
import 'package:admin_my_store/app/repo/order_repository.dart';
import 'package:admin_my_store/app/repo/product_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';


class OrderDetailsController extends GetxController {
  final OrderRepository _repository = Get.find();
  final ProductRepository _productRepository = Get.find();

  final Rx<MyOrder?> order = Rx<MyOrder?>(null);
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = RxString('');

  final List<String> statusList = [
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled'
  ];

  Future<void> loadOrderDetails(String orderId) async {
    try {
      isLoading(true);
      error('');
      final result = await _repository.getOrderById(orderId);
      for (var item in result.items) {
        final product = await _productRepository.getProductById(item.productId);
        if (product != null) {
          products.add(product);
        }
      }
      order.value = result;
    } catch (e) {
      error('Failed to load order details: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateOrderStatus(String newStatus) async {
    try {
      isLoading(true);
      if (order.value != null) {
        await _repository.updateOrderStatus(order.value!.id, newStatus);
        order.update((val) {
          val?.status = newStatus;
          val?.updatedAt = DateTime.now();
        });
      }
    } catch (e) {
      error('Failed to update status: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> sendNotification() async {
    try {
      final order = this.order.value!;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(order.userId)
          .get();

      if (userDoc.exists && userDoc.data()?['fcmToken'] != null) {
        // Send notification using FCM token
        Get.snackbar('Success', 'Notification sent!');
      } else {
        // User does not exist or FCM token is not available
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send notification');
      // print('Error sending notification: $e');
    }
  }
}