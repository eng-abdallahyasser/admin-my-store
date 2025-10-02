import 'package:admin_my_store/app/controllers/auth_controller.dart';
import 'package:admin_my_store/app/controllers/order_controller.dart';
import 'package:admin_my_store/app/widgets/role_guarded_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  AuthController authController = Get.find();
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The OrderController is now initialized via HomeBinding, so we can safely find it.
    final orderController = Get.find<OrderController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final crossAxisCount =
        isMobile
            ? 2
            : screenWidth < 900
            ? 4
            : 5;
    final padding = isMobile ? 10.0 : 20.0;
    final iconSize = isMobile ? 32.0 : 40.0;
    final titleSize = isMobile ? 16.0 : 18.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        elevation: 0,
        actions: [
          IconButton(
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Icon(Icons.logout),
            ),
            onPressed: () {
              authController.logout();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Web-only banner prompting to enable sound alerts
            if (kIsWeb)
              Obx(() {
                final ready = orderController.soundReady.value;
                if (ready) return const SizedBox.shrink();
                return Card(
                  color: Colors.amber.shade50,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.amber.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.volume_up, color: Colors.amber),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Enable sound alerts to hear notifications for new orders.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => orderController.initializeSoundIfNeeded(),
                          child: const Text('Enable sound alerts'),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            if (!isMobile) ...[
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Store Management',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            Expanded(
              child: GridView.count(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.0,
                mainAxisSpacing: padding,
                crossAxisSpacing: padding,
                children: [
                  RoleGuardedWidget(
                    requiredPermission: 'manage_content',
                    child: _buildDashboardTile(
                      context,
                      "Products",
                      Icons.shopping_bag,
                      Colors.blue,
                      iconSize,
                      titleSize,
                      () => Get.toNamed(Routes.products),
                    ),
                  ),
                  RoleGuardedWidget(
                    requiredPermission: 'manage_content',
                    child: _buildDashboardTile(
                      context,
                      "Banners",
                      Icons.image,
                      Colors.indigo,
                      iconSize,
                      titleSize,
                      () => Get.toNamed(Routes.banners),
                    ),
                  ),
                  RoleGuardedWidget(
                    requiredPermission: 'manage_content',
                    child: _buildDashboardTile(
                      context,
                      "Feedback",
                      Icons.feedback,
                      Colors.deepPurple,
                      iconSize,
                      titleSize,
                      () => Get.toNamed(Routes.feedback),
                    ),
                  ),
                  RoleGuardedWidget(
                    requiredPermission: 'view_orders',
                    child: _buildDashboardTile(
                      context,
                      "Orders",
                      Icons.receipt,
                      Colors.green,
                      iconSize,
                      titleSize,
                      () => Get.toNamed(Routes.orders),
                    ),
                  ),

                  RoleGuardedWidget(
                    requiredPermission: 'manage_content',
                    child: _buildDashboardTile(
                      context,
                      "Categories",
                      Icons.category,
                      Colors.orange,
                      iconSize,
                      titleSize,
                      () => Get.toNamed(Routes.categories),
                    ),
                  ),


                  RoleGuardedWidget(
                    requiredPermission: 'view_orders',
                    child: _buildDashboardTile(
                      context,
                      "Customers",
                      Icons.people,
                      Colors.purple,
                      iconSize,
                      titleSize,
                      () {}, // Add your route here
                    ),
                  ),
                  _buildDashboardTile(context, "Manage Roles", 
                      Icons.admin_panel_settings, Colors.teal, iconSize, titleSize,
                      () => Get.toNamed(Routes.userManagement)),
                  
                  _buildDashboardTile(
                    context,
                    "Manage Restaurant",
                    Icons.restaurant,
                    Colors.brown,
                    iconSize,
                    titleSize,
                    () => Get.toNamed(Routes.status),
                  ),
                  if (!isMobile)
                    _buildDashboardTile(
                      context,
                      "Analytics",
                      Icons.analytics,
                      Colors.red,
                      iconSize,
                      titleSize,
                      () {}, // Add your route here
                    ),
                  _buildDashboardTile(
                    context,
                    "Notifications",
                    Icons.notifications,
                    Colors.blueGrey,
                    iconSize,
                    titleSize,
                    () => Get.toNamed(Routes.notifications),
                  ),
                  
                   
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTile(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    double iconSize,
    double titleSize,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
