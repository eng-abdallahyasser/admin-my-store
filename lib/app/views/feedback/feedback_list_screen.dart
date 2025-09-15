import 'package:admin_my_store/app/controllers/feedback_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedbackListScreen extends StatelessWidget {
  FeedbackListScreen({super.key});
  final FeedbackController controller = Get.find<FeedbackController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshList,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Filter by type:'),
                const SizedBox(width: 12),
                Obx(() => DropdownButton<String>(
                      value: controller.selectedType.value,
                      items: controller.types
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) controller.selectedType.value = v;
                      },
                    )),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = controller.filtered;
                if (items.isEmpty) {
                  return const Center(child: Text('No feedback found'));
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final f = items[index];
                    return ListTile(
                      leading: Icon(
                        Icons.feedback,
                        color: _typeColor(f.type),
                      ),
                      title: Text(f.message),
                      subtitle: Text(
                          'Type: ${f.type} • ${controller.formatTimestamp(f.createdAt)} • ${f.userId}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete feedback?'),
                              content: const Text('This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            controller.deleteFeedback(f);
                          }
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Bug':
        return Colors.redAccent;
      case 'Suggestion':
        return Colors.blueAccent;
      case 'Complaint':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
