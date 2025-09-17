import 'dart:async';
import 'dart:developer';

import 'package:admin_my_store/app/models/my_order.dart';
import 'package:admin_my_store/app/repo/order_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';

class OrderController extends GetxController {
  final OrderRepository _repository = Get.find();
  final RxList<MyOrder> orders = <MyOrder>[].obs;
  final Rx<MyOrder?> selectedOrder = Rx<MyOrder?>(null);
  final RxList<String> selectedStatus = <String>[].obs;
  final RxBool isLoading = false.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription<QuerySnapshot> _ordersSubscription;
  bool _initialized = false; // avoid notifying on initial snapshot
  AudioPlayer? _alertPlayer; // used to play looping alert sound
  bool _alerting = false;

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
    _alertPlayer = AudioPlayer();
    _alertPlayer!.setReleaseMode(ReleaseMode.loop);
    // Preload and start muted looping to satisfy web autoplay policies
    // When an alert arrives, we'll raise the volume to 1.0 immediately
    _prewarmAlertLoop();
    super.onInit();
  }

  @override
  void onClose() {
    _ordersSubscription.cancel();
    _alertPlayer?.dispose();
    super.onClose();
  }

  Future<void> _startAlert() async {
    if (_alerting) return;
    _alerting = true;
    await _raiseAlertVolume();

    // Show blocking dialog until user acknowledges
    if (!Get.isDialogOpen!) {
      Get.dialog(
        AlertDialog(
          title: const Text('New Order Received'),
          content: const Text('One or more new orders have arrived.'),
          actions: [
            TextButton(
              onPressed: acknowledgeNewOrders,
              child: const Text('Acknowledge'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  Future<void> acknowledgeNewOrders() async {
    try {
      // Lower volume back to 0.0 but keep looping to maintain autoplay allowance
      await _alertPlayer?.setVolume(0.0);
    } catch (_) {}
    _alerting = false;
    if (Get.isDialogOpen!) Get.back();
  }

  Future<void> _prewarmAlertLoop() async {
    try {
      // Start playing looped asset at zero volume
      await _alertPlayer?.setVolume(0.0);
      await _alertPlayer?.play(AssetSource('sounds/new_order.mp3'));
    } catch (_) {
      // As a fallback on mobile devices, ensure at least a system sound works later
    }
  }

  Future<void> _raiseAlertVolume() async {
    try {
      await _alertPlayer?.setVolume(1.0);
    } catch (_) {
      // Fallback attempts (mobile native or system sound)
      try {
        if (!kIsWeb) await FlutterRingtonePlayer.playNotification();
      } catch (_) {
        try { await SystemSound.play(SystemSoundType.alert); } catch (_) {}
      }
    }
  }

  void _startListening() {
    _ordersSubscription = _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) async {
          // Always keep local list in sync
          orders.assignAll(
            snapshot.docs.map((doc) => MyOrder.fromFirestore(doc)).toList(),
          );

          // Skip notifications on the very first load
          if (!_initialized) {
            _initialized = true;
            return;
          }

          // Detect newly added orders
          final addedChanges = snapshot.docChanges
              .where((c) => c.type == DocumentChangeType.added)
              .toList();

          if (addedChanges.isNotEmpty) {
            // Start sound alert (looping) and show blocking popup until user action
            await _startAlert();
          }
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
      final response = await _repository.getOrders(statusFilters: selectedStatus);
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

  void applyFilters() {}
}