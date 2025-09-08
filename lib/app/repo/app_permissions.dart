// Define role permissions
class AppPermissions {


  static const Map<String, List<String>> rolePermissions = {
    'super_admin': ['all'],
    'admin': [
      'manage_users', 'manage_restaurant', 'view_reports',
      'edit_settings', 'manage_content'
    ],
    'manager': [
      'manage_restaurant', 'view_reports', 'edit_settings',
      'manage_content'
    ],
    'editor': ['manage_content', 'view_reports'],
    'viewer': ['view_reports'],
  };

  static bool can(String permission, List<String> userRoles) {
    if (userRoles.contains('super_admin')) return true;
    
    for (var role in userRoles) {
      if (rolePermissions[role]?.contains('all') == true) return true;
      if (rolePermissions[role]?.contains(permission) == true) return true;
    }
    
    return false;
  }

  // Get all available roles
  static List<String> get availableRoles => rolePermissions.keys.toList();

  
}