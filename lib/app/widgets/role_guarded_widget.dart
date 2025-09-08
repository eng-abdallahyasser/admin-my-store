import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RoleGuardedWidget extends StatelessWidget {
  final Widget child;
  final String requiredPermission;
  final Widget? fallbackWidget;

  const RoleGuardedWidget({
    super.key,
    required this.child,
    required this.requiredPermission,
    this.fallbackWidget,
  });

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    
    return Obx(() {
      if (authController.hasPermission(requiredPermission)) {
        return child;
      }
      
      return fallbackWidget ?? SizedBox.shrink();
    });
  }
}

// Example usage:
// RoleGuardedWidget(
//   requiredPermission: 'manage_users',
//   child: ElevatedButton(
//     onPressed: () => navigateToUserManagement(),
//     child: Text('Manage Users'),
//   ),
//   fallbackWidget: Tooltip(
//     message: 'Insufficient permissions',
//     child: ElevatedButton(
//       onPressed: null,
//       child: Text('Manage Users'),
//     ),
//   ),
// )