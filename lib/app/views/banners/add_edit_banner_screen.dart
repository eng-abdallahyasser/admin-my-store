import 'package:admin_my_store/app/controllers/banner_controller.dart';
import 'package:admin_my_store/app/controllers/product_controller.dart';
import 'package:admin_my_store/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/banner/banner_model.dart' as models;

class AddEditBannerScreen extends StatelessWidget {
  AddEditBannerScreen({super.key});

  final BannerController controller = Get.find<BannerController>();
  final ProductController productController = Get.find<ProductController>();

  bool get _isEdit => Get.currentRoute == Routes.editBanner;

  final RxString _productSearchQuery = ''.obs;

  // Observable for banner type to make it reactive
  final RxString _bannerType = ''.obs;

  void _showProductPicker() {
    _productSearchQuery.value = '';
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Select Product'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Obx(() {
            if (productController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (productController.products.isEmpty) {
              return const Center(child: Text('No products available'));
            }

            // Filter products based on search query
            final filteredProducts = _productSearchQuery.value.isEmpty
                ? productController.products
                : productController.products.where((product) {
                    return product.title.toLowerCase().contains(_productSearchQuery.value.toLowerCase()) ||
                           product.id.toLowerCase().contains(_productSearchQuery.value.toLowerCase());
                  }).toList();

            if (filteredProducts.isEmpty) {
              return const Center(child: Text('No products match your search'));
            }

            return Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _productSearchQuery.value = value;
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ListTile(
                        leading: product.imagesUrl.isNotEmpty
                            ? Image.network(
                                product.imagesUrl[0],
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image, size: 40),
                        title: Text(product.title),
                        subtitle: Text('ID: ${product.id}'),
                        onTap: () {
                          controller.productIdController.text = product.id;
                          Get.back();
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

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
      // Set the observable banner type
      _bannerType.value = banner.type ?? '';
    } else {
      // Ensure fresh state for Add mode
      controller.clearForm();
      _bannerType.value = '';
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Banner' : 'Add Banner')),
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
                      DropdownButtonFormField<String>(
                        initialValue: _bannerType.value.isEmpty ? null : _bannerType.value,
                        decoration: const InputDecoration(
                          labelText: 'Banner Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'product_linked_banner',
                            child: Text('Product Linked Banner'),
                          ),
                          DropdownMenuItem(
                            value: 'not_linked_banner',
                            child: Text('Not Linked Banner'),
                          ),
                        ],
                        onChanged: (value) {
                          _bannerType.value = value ?? '';
                          controller.typeController.text = value ?? '';
                          // Clear product ID if switching to not linked banner
                          if (value == 'not_linked_banner') {
                            controller.productIdController.clear();
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a banner type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Obx(() {
                        final isProductLinked = _bannerType.value == 'product_linked_banner';
                        return Column(
                          children: [
                            TextField(
                              controller: controller.productIdController,
                              decoration: InputDecoration(
                                labelText: isProductLinked
                                    ? 'Product ID (required)'
                                    : 'Product ID (optional)',
                                border: const OutlineInputBorder(),
                                suffixIcon: isProductLinked
                                    ? IconButton(
                                        icon: const Icon(Icons.search),
                                        onPressed: _showProductPicker,
                                      )
                                    : null,
                              ),
                              readOnly: isProductLinked,
                              onTap: isProductLinked ? _showProductPicker : null,
                            ),
                            if (isProductLinked)
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Tap to select a product',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
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
                                        child: Icon(
                                          Icons.image,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
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
                          ),
                        ],
                      );
                    }),
                  ),
                ),
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
            }),
          ],
        ),
      ),
    );
  }
}
