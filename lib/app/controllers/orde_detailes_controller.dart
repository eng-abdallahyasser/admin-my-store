import 'package:admin_my_store/app/models/order.dart';
import 'package:admin_my_store/app/repo/order_repository.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';


class OrderDetailsController extends GetxController {
  final OrderRepository _repository = Get.find();
  final Rx<MyOrder?> order = Rx<MyOrder?>(null);
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

  void sendOrderUpdateNotification(String id) {

  }
}