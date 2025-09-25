import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:admin_my_store/app/repo/notification_repository.dart';

class NotificationsController extends GetxController {
  final NotificationRepository _notificationRepository = Get.find();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  final RxBool isSending = false.obs;

  @override
  void onClose() {
    titleController.dispose();
    bodyController.dispose();
    imageUrlController.dispose();
    super.onClose();
  }

  

  Future<void> sendToAllUsers() async {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();
    final imageUrl =
        imageUrlController.text.trim().isEmpty
            ? null
            : imageUrlController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      Get.snackbar('Missing fields', 'Please enter title and body');
      return;
    }

    try {
      isSending(true);
      await _notificationRepository.sendToTopic(
        topic: 'all-users',
        title: title,
        body: body,
        data: <String, dynamic>{'broadcast': 'true'},
        imageUrl: imageUrl,
      );
      Get.snackbar('Success', 'Notification sent to all users');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send notification');
    } finally {
      isSending(false);
    }
  }
}
