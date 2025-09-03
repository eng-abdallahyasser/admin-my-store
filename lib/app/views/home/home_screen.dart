import 'package:admin_my_store/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  AuthController authController = Get.find();
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final crossAxisCount =
        isMobile
            ? 2
            : screenWidth < 900
            ? 3
            : 4;
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
                  _buildDashboardTile(
                    context,
                    "Products",
                    Icons.shopping_bag,
                    Colors.blue,
                    iconSize,
                    titleSize,
                    () => Get.toNamed(Routes.products),
                  ),
                  _buildDashboardTile(
                    context,
                    "Orders",
                    Icons.receipt,
                    Colors.green,
                    iconSize,
                    titleSize,
                    () => Get.toNamed(Routes.orders),
                  ),
                  _buildDashboardTile(
                    context,
                    "Categories",
                    Icons.category,
                    Colors.orange,
                    iconSize,
                    titleSize,
                    () => Get.toNamed(Routes.categories),
                  ),
                  _buildDashboardTile(
                    context,
                    "Customers",
                    Icons.people,
                    Colors.purple,
                    iconSize,
                    titleSize,
                    () {}, // Add your route here
                  ),
                  _buildDashboardTile(
                    context,
                    "Status",
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
                  if (!isMobile)
                    _buildDashboardTile(
                      context,
                      "Settings",
                      Icons.settings,
                      Colors.teal,
                      iconSize,
                      titleSize,
                      () {}, // Add your route here
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
