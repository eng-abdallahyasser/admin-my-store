class RestaurantStatus {
  String id;
  String name;
  bool isOpen;
  String closedMessage;
  Map<String, dynamic> openingHours;
  bool autoMode;
  String minAppVersion;

  RestaurantStatus({
    required this.id,
    required this.name,
    required this.isOpen,
    required this.closedMessage,
    required this.openingHours,
    required this.autoMode,
    required this.minAppVersion,
  });

  factory RestaurantStatus.fromMap(String id, Map<String, dynamic> data) {
    // Set default opening hours if none exist
    Map<String, dynamic> defaultHours = {
      'monday': {'open': '07:00', 'close': '23:00', 'enabled': true},
      'tuesday': {'open': '07:00', 'close': '23:00', 'enabled': true},
      'wednesday': {'open': '07:00', 'close': '23:00', 'enabled': true},
      'thursday': {'open': '07:00', 'close': '23:00', 'enabled': true},
      'friday': {'open': '07:00', 'close': '23:00', 'enabled': true},
      'saturday': {'open': '08:00', 'close': '23:00', 'enabled': true},
      'sunday': {'open': '08:00', 'close': '22:00', 'enabled': true},
    };

    return RestaurantStatus(
      id: id,
      name: data['name'] ?? '',
      isOpen: data['isOpen'] ?? false,
      closedMessage: data['closedMessage'] ?? 'Restaurant is closed',
      openingHours: Map<String, dynamic>.from(data['openingHours'] ?? defaultHours),
      autoMode: data['autoMode'] ?? true,
      minAppVersion: data['minAppVersion'] ?? '1.0.0',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isOpen': isOpen,
      'closedMessage': closedMessage,
      'openingHours': openingHours,
      'autoMode': autoMode,
      'minAppVersion': minAppVersion,
    };
  }
}