import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_my_store/app/controllers/notifications_controller.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  final NotificationsController _controller = Get.find<NotificationsController>();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final content = _buildForm(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Send Notification to All Users')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: isWide
                ? Row(
                    children: [
                      Expanded(child: content),
                      const SizedBox(width: 24),
                      Expanded(child: _buildHelpCard()),
                    ],
                  )
                : ListView(
                    children: [
                      content,
                      const SizedBox(height: 16),
                      _buildHelpCard(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller.titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller.bodyController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Body',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller.imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _controller.isSending.value ? null : _controller.sendToAllUsers,
                  icon: _controller.isSending.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send),
                  label: Text(_controller.isSending.value ? 'Sending...' : 'Send to All Users'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard() {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('How it works', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('- This will send a push notification to everyone subscribed to the "all-users" topic.'),
            SizedBox(height: 6),
            Text('- Make sure your mobile app subscribes to the topic: FirebaseMessaging.instance.subscribeToTopic("all-users").'),
            SizedBox(height: 6),
            Text('- Optionally include an image URL that appears in supported platforms.'),
          ],
        ),
      ),
    );
  }
}
