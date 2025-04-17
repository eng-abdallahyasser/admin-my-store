import 'dart:async';
import 'dart:developer';

import 'package:admin_my_store/app/models/my_order.dart';
import 'package:admin_my_store/app/repo/order_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';


class OrderController extends GetxController {
  final OrderRepository _repository = Get.find();
  final RxList<MyOrder> orders = <MyOrder>[].obs;
  final Rx<MyOrder?> selectedOrder = Rx<MyOrder?>(null);
  final RxList<String> selectedStatus = <String>[].obs;
  final RxBool isLoading = false.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription<QuerySnapshot> _ordersSubscription;

  
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
    _startListening();
    super.onInit();
  }
  void _startListening() {
    _ordersSubscription = _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          orders.assignAll(
            snapshot.docs.map((doc) => MyOrder.fromFirestore(doc)).toList()
          );
        });
  }
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
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

  // @override
  // void onReady() {
  //   final orderId = Get.arguments as String;
  //   loadOrderDetails(orderId);
  //   super.onReady();
  // }

  Future<MyOrder?> loadOrderDetails(String orderId) async {
    try {
      isLoading(true);
      final response = await _repository.getOrderById(orderId);
      selectedOrder.value = response;
      return response;
    } catch (e) {
      log(e.toString());
      Get.snackbar('Error', 'Failed to load order details');
      return null;
    } finally {
      isLoading(false);
    }
  }

  // Future<void> updateOrderStatus(String orderId, String newStatus) async {
  //   try {
  //     isLoading(true);
  //     await _repository.updateOrderStatus(orderId, newStatus);
  //     final index = orders.indexWhere((o) => o.id == orderId);
  //     if (index != -1) {
  //       orders[index] = orders[index].copyWith(status: newStatus);
  //     }
  //     Get.snackbar('Success', 'Order status updated');
  //   } catch (e) {
  //     log(e.toString());
  //     Get.snackbar('Error', 'Failed to update status');
  //   } finally {
  //     isLoading(false);
  //   }
  // }

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