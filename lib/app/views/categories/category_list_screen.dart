import 'package:admin_my_store/app/controllers/category_controller.dart';
import 'package:admin_my_store/app/routes/app_routes.dart';
import 'package:admin_my_store/app/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CategoryListScreen extends StatelessWidget {
  final CategoryController _controller = Get.find();

  CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(Routes.addCategory),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _controller.categories.length,
          itemBuilder: (context, index) {
            final category = _controller.categories[index];
            return CategoryCard(
              category: category,
              onEdit: () => {},
              onDelete: () => _controller.deleteCategory(category.id),
            );
          },
        );
      }),
    );
  }
}