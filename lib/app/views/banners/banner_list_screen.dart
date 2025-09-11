import 'package:admin_my_store/app/controllers/banner_controller.dart';
import 'package:admin_my_store/app/routes/app_routes.dart';
import 'package:admin_my_store/app/widgets/banner_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BannerListScreen extends StatelessWidget {
  BannerListScreen({super.key});
  final BannerController controller = Get.find<BannerController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banners'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadBanners,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.clearForm();
          Get.toNamed(Routes.addBanner);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Banner'),
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.banners.isEmpty) {
            return const Center(child: Text('No banners found'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.6,
              ),
              itemCount: controller.banners.length,
              itemBuilder: (context, index) {
                final banner = controller.banners[index];
                return BannerCard(
                  title: banner.title ?? 'Untitled',
                  imageUrl: banner.image ?? '',
                  subtitle: banner.link ?? '',
                  onEdit: () async {
                    await controller.initializeForEdit(banner);
                    Get.toNamed(Routes.editBanner, arguments: banner);
                  },
                  onDelete: () {
                    final id = banner.id;
                    if (id != null) controller.deleteBanner(id);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
