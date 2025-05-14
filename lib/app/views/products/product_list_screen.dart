import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_my_store/app/controllers/product_controller.dart';
import 'package:admin_my_store/app/models/product.dart';
import 'package:admin_my_store/app/routes/app_routes.dart';
import 'package:admin_my_store/app/widgets/product_card.dart';

class ProductListScreen extends StatelessWidget {
  final ProductController productController = Get.find();

  ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
            tooltip: 'Search Products',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter Products',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Get.toNamed(Routes.addProduct),
        tooltip: 'Add New Product',
      ),
      body: Obx(() {
        if (productController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (productController.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No Products Found',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add a new product',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : isTablet ? 4 : 6,
              childAspectRatio: isMobile ? 0.75 : 1.2,
              crossAxisSpacing: isMobile ? 8.0 : 16.0,
              mainAxisSpacing: isMobile ? 8.0 : 16.0,
            ),
            itemCount: productController.products.length,
            itemBuilder: (context, index) {
              final product = productController.products[index];
              return ProductCard(
                product: product,
                onEdit: () => Get.toNamed(Routes.editProduct, arguments: product.id),
                onDelete: () => _confirmDelete(product),
              );
            },
          ),
        );
      }),
    );
  }

  void _confirmDelete(Product product) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              productController.deleteProduct(product.id);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Products'),
          content: SizedBox(
            width: double.minPositive,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterOption('All Products', Icons.all_inclusive),
                _buildFilterOption('In Stock', Icons.inventory),
                _buildFilterOption('Out of Stock', Icons.inventory_2),
                _buildFilterOption('Featured', Icons.star),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        // Implement filter logic
        Get.back();
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Products'),
          content: TextField(
            decoration: const InputDecoration(
              hintText: 'Enter product name...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              // Implement search logic
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}