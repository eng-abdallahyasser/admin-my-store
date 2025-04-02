import 'dart:developer';

import 'package:admin_my_store/app/models/order.dart';
import 'package:admin_my_store/app/repo/order_repository.dart';
import 'package:get/get.dart';


class OrderController extends GetxController {
  final OrderRepository _repository = Get.find();
  final RxList<MyOrder> orders = <MyOrder>[].obs;
  final Rx<MyOrder?> selectedOrder = Rx<MyOrder?>(null);
  final RxList<String> selectedStatus = <String>[].obs;
  final RxBool isLoading = false.obs;
  
  final List<String> statusList = [
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled'
  ];

  @override
  void onInit() {
    loadOrders();
    super.onInit();
  }

  Future<void> loadOrders() async {
    try {
      isLoading(true);
      final response = await _repository.getOrders();
      log(response[0].id);
      orders.value = response;
    } catch (e) {
      log(e.toString());
      Get.snackbar('Error', 'Failed to load orders: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadOrderDetails(String orderId) async {
    try {
      isLoading(true);
      selectedOrder.value = await _repository.getOrderById(orderId);
    } catch (e) {
      log(e.toString());
      Get.snackbar('Error', 'Failed to load order details');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      isLoading(true);
      await _repository.updateOrderStatus(orderId, newStatus);
      final index = orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        orders[index] = orders[index].copyWith(status: newStatus);
      }
      Get.snackbar('Success', 'Order status updated');
    } catch (e) {
      log(e.toString());
      Get.snackbar('Error', 'Failed to update status');
    } finally {
      isLoading(false);
    }
  }

  void toggleStatusFilter(String status) {
    if (selectedStatus.contains(status)) {
      selectedStatus.remove(status);
    } else {
      selectedStatus.add(status);
    }
    loadOrders();
  }

  Future<void> sendOrderUpdateNotification(String orderId) async {
    try {
      isLoading(true);
      await _repository.sendNotification(orderId);
      Get.snackbar('Success', 'Notification sent to customer');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send notification');
    } finally {
      isLoading(false);
    }
  }
}