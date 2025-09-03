class RestaurantStatus {
  String id;
  String name;
  bool isOpen;
  String closedMessage;
  Map<String, dynamic> openingHours;

  RestaurantStatus({
    required this.id,
    required this.name,
    required this.isOpen,
    required this.closedMessage,
    required this.openingHours,
  });

  factory RestaurantStatus.fromMap(String id, Map<String, dynamic> data) {
    return RestaurantStatus(
      id: id,
      name: data['name'] ?? '',
      isOpen: data['isOpen'] ?? false,
      closedMessage: data['closedMessage'] ?? 'Restaurant is closed',
      openingHours: Map<String, dynamic>.from(data['openingHours'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isOpen': isOpen,
      'closedMessage': closedMessage,
      'openingHours': openingHours,
    };
  }
}