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
  // Exposed flag so UI can prompt user to enable sound on web
  final RxBool soundReady = false.obs;

  final List<String> statusList = [
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  @override
  void onInit() {
    loadOrders();
    _startListening();
    _alertPlayer = AudioPlayer();
    _alertPlayer!.setReleaseMode(ReleaseMode.loop);
    // Log controller identity to help detect duplicate instances at runtime
    log('OrderController initialized: ${identityHashCode(this)}');
    // On mobile/desktop native, we can prewarm immediately.
    // On web, defer prewarm until a user gesture calls initializeSoundIfNeeded().
    if (!kIsWeb) {
      _prewarmAlertLoop().then((_) => soundReady.value = true);
    }
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
    // Use safe null-aware check for dialog open state
    if (Get.isDialogOpen != true) {
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
      // Acknowledge: for web we keep the loop playing at volume 0.0 to preserve
      // autoplay allowance; for native platforms it's safer to stop the player.
      log('Acknowledging new orders (controller ${identityHashCode(this)}');
      if (kIsWeb) {
        await _alertPlayer?.setVolume(0.0);
      } else {
        // Stop playback to ensure the sound does not restart from another
        // surviving player instance. If needed, re-prewarm later.
        await _alertPlayer?.stop();
      }
    } catch (e, s) {
      log(
        'Error setting volume to 0 in acknowledgeNewOrders: $e',
        stackTrace: s,
      );
    }
    _alerting = false;
    if (Get.isDialogOpen == true) Get.back();
  }

  Future<void> _prewarmAlertLoop() async {
    try {
      log('Prewarming alert loop...');
      _alertPlayer ??= AudioPlayer();
      await _alertPlayer!.setReleaseMode(ReleaseMode.loop);
      await _alertPlayer!.setVolume(0.0);
      await _alertPlayer!.play(AssetSource('sounds/new_order.mp3'));
      log('Audio prewarm successful.');
    } catch (e, s) {
      log('Error prewarming alert loop: $e', stackTrace: s);
      // Fallback will be handled in _raiseAlertVolume
    }
  }

  /// Call this from a user gesture (e.g., a button tap) to enable sound on web.
  Future<void> initializeSoundIfNeeded() async {
    if (soundReady.value) return;
    log('Initializing sound for web via user gesture...');
    await _prewarmAlertLoop();
    soundReady.value = true;
    try {
      Get.snackbar('Sound enabled', 'Audio alerts will play for new orders');
    } catch (e) {
      log('Could not show "Sound enabled" snackbar: $e');
    }
  }

  Future<void> _raiseAlertVolume() async {
    try {
      log('New order received, raising alert volume to 1.0...');
      await _alertPlayer?.setVolume(1.0);
      log('Audio volume raised successfully.');
    } catch (e, s) {
      log('Error raising alert volume: $e', stackTrace: s);
      // Fallback attempts
      try {
        await FlutterRingtonePlayer.playNotification();
      } catch (e2, s2) {
        log('Could not play fallback notification sound: $e2', stackTrace: s2);
        try {
          await SystemSound.play(SystemSoundType.alert);
        } catch (e3, s3) {
          log('Could not play system alert sound: $e3', stackTrace: s3);
        }
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
          final addedChanges =
              snapshot.docChanges
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
      final response = await _repository.getOrders(
        statusFilters: selectedStatus,
      );
      orders.value = response;
    } catch (e) {
      log(e.toString());
      Get.snackbar('Error', 'Failed to load orders: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

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
