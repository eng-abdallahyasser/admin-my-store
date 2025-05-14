import 'package:admin_my_store/app/controllers/category_controller.dart';
import 'package:admin_my_store/app/routes/app_routes.dart';
import 'package:admin_my_store/app/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
        return LayoutBuilder(
          builder: (context, constraints) {
            // Use a different grid layout for wider screens
            if (constraints.maxWidth > 600) {
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithResponsive( // Use Responsive Delegate
                  maxCrossAxisExtent: 300,  // max width of a grid item
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: _controller.categories.length,
                itemBuilder: (context, index) {
                  final category = _controller.categories[index];
                  return CategoryCard(
                    category: category,
                    onEdit: () => {}, // Implement edit functionality
                    onDelete: () => _controller.deleteCategory(category.id),
                  );
                },
              );
            } else {  // For smaller screens
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
            }
          },
        );
      }),
    );
  }
}

// A responsive grid delegate.  Use this instead of SliverGridDelegateWithFixedCrossAxisCount for web
class SliverGridDelegateWithResponsive extends SliverGridDelegate {
  SliverGridDelegateWithResponsive({
    required this.maxCrossAxisExtent,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.crossAxisCount,
  }) : assert(crossAxisCount == null || crossAxisCount > 0);

  final double maxCrossAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final int? crossAxisCount;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final int crossAxisCount = this.crossAxisCount ??
        (constraints.crossAxisExtent / maxCrossAxisExtent).ceil();
    final double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final double childMainAxisExtent = childCrossAxisExtent / childAspectRatio;
    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.axisDirection),
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithResponsive oldDelegate) {
    return oldDelegate.maxCrossAxisExtent != maxCrossAxisExtent ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.childAspectRatio != childAspectRatio;
  }
}
