import 'package:admin_my_store/app/controllers/banner_controller.dart';
import 'package:admin_my_store/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/banner/banner_model.dart' as models;

class AddEditBannerScreen extends StatelessWidget {
  AddEditBannerScreen({super.key});

  final BannerController controller = Get.find<BannerController>();

  bool get _isEdit => Get.currentRoute == Routes.editBanner;

  models.Banner? get _argBanner {
    final arg = Get.arguments;
    if (arg is models.Banner) return arg;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // If edit, initialize with passed banner
    final banner = _argBanner;
    if (_isEdit && banner != null) {
      controller.initializeForEdit(banner);
    } else {
      // Ensure fresh state for Add mode
      controller.clearForm();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Banner' : 'Add Banner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: controller.titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.linkController,
                        decoration: const InputDecoration(
                          labelText: 'Link (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.typeController,
                        decoration: const InputDecoration(
                          labelText: 'Type (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 360,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Obx(() {
                      final bytes = controller.imageBytes.value;
                      final url = controller.existingImageUrl.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            child: bytes != null
                                ? Image.memory(bytes, fit: BoxFit.cover)
                                : (url != null && url.isNotEmpty)
                                    ? Image.network(url, fit: BoxFit.cover)
                                    : const Center(
                                        child: Icon(Icons.image, size: 48, color: Colors.grey),
                                      ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: controller.pickImage,
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Select Image'),
                                ),
                                const SizedBox(width: 12),
                                if (bytes != null || (url != null && url.isNotEmpty))
                                  TextButton.icon(
                                    onPressed: () {
                                      controller.imageBytes.value = null;
                                      controller.existingImageUrl.value = null;
                                    },
                                    icon: const Icon(Icons.clear),
                                    label: const Text('Clear'),
                                  ),
                              ],
                            ),
                          )
                        ],
                      );
                    }),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            Obx(() {
              return Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (_isEdit && banner?.id != null) {
                            controller.updateBanner(banner!.id!);
                          } else {
                            controller.addBanner();
                          }
                        },
                  icon: Icon(_isEdit ? Icons.save : Icons.add),
                  label: Text(_isEdit ? 'Save Changes' : 'Add Banner'),
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
