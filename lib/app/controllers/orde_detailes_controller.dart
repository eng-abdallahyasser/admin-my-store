import 'package:admin_my_store/app/models/my_order.dart';
import 'package:admin_my_store/app/models/product.dart';
import 'package:admin_my_store/app/repo/order_repository.dart';
import 'package:admin_my_store/app/repo/product_repository.dart';
import 'package:admin_my_store/app/repo/notification_repository.dart';
import 'package:admin_my_store/app/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';


class OrderDetailsController extends GetxController {
  final OrderRepository _repository = Get.find();
  final ProductRepository _productRepository = Get.find();
  final NotificationRepository _notificationRepository = Get.find();

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
        products.add(product);
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
      final currentOrder = order.value;
      if (currentOrder == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentOrder.userId)
          .get();

      if (!userDoc.exists) {
        Get.snackbar('User not found', 'Cannot send notification');
        return;
      }

      final data = userDoc.data() ?? {};
      final tokens = <String>{};
      if (data['fcmTokens'] is List) {
        tokens.addAll(List<String>.from(data['fcmTokens'] as List));
      }
      if (data['fcmToken'] is String && (data['fcmToken'] as String).isNotEmpty) {
        tokens.add(data['fcmToken'] as String);
      }

      if (tokens.isEmpty) {
        Get.snackbar('No device tokens', 'Customer has no registered devices');
        return;
      }

      final title = 'Order Confirmed';
      final body = 'Your order #${currentOrder.orderNumber} is now Confirmed, Thank you for your order';
      final payload = {
        'route': Routes.orderDetails,
        'orderId': currentOrder.id,
      };
      final type='order';

      for (final t in tokens) {
        await _notificationRepository.sendToToken(
          token: t,
          title: title,
          body: body,
          data: payload,
          type: type,
        );
      }

      Get.snackbar('Success', 'Notification sent to customer');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send notification');
    }
  }
}