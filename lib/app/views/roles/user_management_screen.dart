import 'package:admin_my_store/app/controllers/auth_controller.dart';
import 'package:admin_my_store/app/models/app_user.dart';
import 'package:admin_my_store/app/repo/app_permissions.dart';
import 'package:admin_my_store/app/widgets/role_guarded_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Auto-load users after first frame if the user has permission
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_authController.hasPermission('manage_users')) {
        await _authController.getUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        centerTitle: true,
      ),
      body: RoleGuardedWidget(
        requiredPermission: 'manage_users',
        fallbackWidget: Center(
          child: Text('You do not have permission to manage users.'),
        ),
        child: Obx(() {
          if (_authController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage User Roles',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _authController.users.length,
                    itemBuilder: (context, index) {
                      final user = _authController.users[index];
                      // Skip the currently logged-in user
                      final currentUid = _authController.user.value?.uid;
                      if (currentUid != null && user.uid == currentUid) {
                        return SizedBox.shrink();
                      }
                      return _UserRoleCard(user: user, authController: _authController);
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: RoleGuardedWidget(
        requiredPermission: 'manage_users',
        child: FloatingActionButton(
          onPressed: _authController.getUsers,
          tooltip: 'Refresh Users',
          child: Icon(Icons.refresh),
        ),
      ),
    );
  }
}

class _UserRoleCard extends StatefulWidget {
  final AppUser user;
  final AuthController authController;

  const _UserRoleCard({required this.user, required this.authController});

  @override
  __UserRoleCardState createState() => __UserRoleCardState();
}

class __UserRoleCardState extends State<_UserRoleCard> {
  late List<String> _selectedRoles;

  @override
  void initState() {
    super.initState();
    _selectedRoles = List.from(widget.user.roles);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    widget.user.displayName.isNotEmpty 
                      ? widget.user.displayName[0].toUpperCase()
                      : 'U',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.displayName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        widget.user.email,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            Text('Assign Roles:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            
            // Horizontal role chips with ListView.builder
            SizedBox(
              height: 40,
              child: ListView.builder(
                itemCount: AppPermissions.availableRoles.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return _buildRoleChip(AppPermissions.availableRoles[index]);
                },
              ),
            ),
            
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Selected: ${_selectedRoles.join(', ')}',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveRoles,
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    final isSelected = _selectedRoles.contains(role);
    
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(role),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              // Add role selection logic with hierarchy
              _updateRoleSelection(role);
            } else {
              _selectedRoles.remove(role);
            }
          });
        },
        backgroundColor: isSelected ? _getRoleColor(role) : Colors.grey[200],
        selectedColor: _getRoleColor(role),
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }

  void _updateRoleSelection(String newRole) {
    // Clear conflicting roles based on hierarchy
    switch (newRole) {
      case 'super_admin':
        _selectedRoles = ['super_admin'];
        break;
      case 'admin':
        _selectedRoles.removeWhere((r) => 
          r == 'manager' || r == 'editor' || r == 'viewer');
        _selectedRoles.add('admin');
        break;
      case 'manager':
        _selectedRoles.removeWhere((r) => 
          r == 'editor' || r == 'viewer');
        _selectedRoles.add('manager');
        break;
      case 'editor':
        _selectedRoles.removeWhere((r) => r == 'viewer');
        _selectedRoles.add('editor');
        break;
      case 'viewer':
        _selectedRoles.add('viewer');
        break;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'super_admin':
        return Colors.purple;
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      case 'editor':
        return Colors.blue;
      case 'viewer':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _saveRoles() async {
    try {
      await widget.authController.updateUserRoles(widget.user.uid, _selectedRoles);
      Get.snackbar('Success', 'User roles updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update roles: $e');
    }
  }
}