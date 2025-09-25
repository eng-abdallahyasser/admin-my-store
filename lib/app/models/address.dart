import 'dart:convert';

class Address {
  String userId;
  String addressId;
  String name;
  double latitude;
  double longitude;
  String address;
  String phoneNumber;
  String area; // منطقة
  String street; // شارع
  String building; // عمارة
  String floor; // دور
  String apartment; // شقة
  String landmark; // علامة مميزة
  Address({
    required this.userId,
    required this.addressId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.phoneNumber,
    required this.area,
    required this.street,
    required this.building,
    required this.floor,
    required this.apartment,
    required this.landmark,
  });
 

  Address copyWith({
    String? userId,
    String? addressId,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    String? phoneNumber,
    String? area,
    String? street,
    String? building,
    String? floor,
    String? apartment,
    String? landmark,
  }) {
    return Address(
      userId: userId ?? this.userId,
      addressId: addressId ?? this.addressId,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      area: area ?? this.area,
      street: street ?? this.street,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      landmark: landmark ?? this.landmark,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'addressId': addressId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phoneNumber': phoneNumber,
      'area': area,
      'street': street,
      'building': building,
      'floor': floor,
      'apartment': apartment,
      'landmark': landmark,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      userId: map['userId'] as String,
      addressId: map['addressId'] as String,
      name: map['name'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      address: map['address'] as String,
      phoneNumber: map['phoneNumber'] as String,
      area: map['area'] as String? ?? '',
      street: map['street'] as String? ?? '',
      building: map['building'] as String? ?? '',
      floor: map['floor'] as String? ?? '',
      apartment: map['apartment'] as String? ?? '',
      landmark: map['landmark'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Address.fromJson(String source) => Address.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Returns a formatted address string for display purposes
  String getFormattedAddress() {
    List<String> parts = [];
    
    if (name.isNotEmpty) parts.add('Name: $name');
    if (address.isNotEmpty) parts.add('Address: $address');
    if (latitude!=0.0) parts.add('Latitude: $latitude');
    if (longitude!=0.0) parts.add('Longitude: $longitude');
    if (addressId.isNotEmpty) parts.add('Address ID: $addressId');
    if (area.isNotEmpty) parts.add('Area: $area (منطقة)');
    if (street.isNotEmpty) parts.add('Street: $street (شارع)');
    if (building.isNotEmpty) parts.add('Building: $building (عمارة)');
    if (floor.isNotEmpty) parts.add('Floor: $floor (دور)');
    if (apartment.isNotEmpty) parts.add('Apartment: $apartment (شقة)');
    if (landmark.isNotEmpty) parts.add('Landmark: $landmark (علامة مميزة)');
    if (phoneNumber.isNotEmpty) parts.add('Phone: $phoneNumber');
    
    return parts.join('\n');
  }
  static Address fromCompactAddress(String compactAddress) {
    // Initialize with default values
    String name = '';
    String address = '';
    double latitude = 0.0;
    double longitude = 0.0;
    String addressId = '';
    String area = '';
    String street = '';
    String building = '';
    String floor = '';
    String apartment = '';
    String landmark = '';
    String phoneNumber = '';
    
    // Split the compact address by comma and space
    List<String> parts = compactAddress.split(', ');
    
    for (String part in parts) {
      part = part.trim();
      
      if (part.startsWith('Latitude: ')) {
        latitude = double.tryParse(part.substring(10)) ?? 0.0;
      } else if (part.startsWith('Longitude: ')) {
        longitude = double.tryParse(part.substring(11)) ?? 0.0;
      } else if (part.startsWith('addressId: ')) {
        addressId = part.substring(11);
      } else if (part.startsWith('Area: ')) {
        area = part.substring(6);
      } else if (part.startsWith('Street: ')) {
        street = part.substring(8);
      } else if (part.startsWith('Building: ')) {
        building = part.substring(10);
      } else if (part.startsWith('Floor: ')) {
        floor = part.substring(7);
      } else if (part.startsWith('Apartment: ')) {
        apartment = part.substring(11);
      } else if (part.startsWith('Landmark: ')) {
        landmark = part.substring(10);
      } else if (part.startsWith('Phone: ')) {
        phoneNumber = part.substring(7);
      } else {
        // If no prefix, it's either name or address
        // First non-prefixed part is name, second is address
        if (name.isEmpty) {
          name = part;
        } else if (address.isEmpty) {
          address = part;
        }
      }
    }
    
    return Address(
      userId: '', // Will need to be set separately
      addressId: addressId,
      name: name,
      latitude: latitude,
      longitude: longitude,
      address: address,
      phoneNumber: phoneNumber,
      area: area,
      street: street,
      building: building,
      floor: floor,
      apartment: apartment,
      landmark: landmark,
    );
  }

  /// Returns a compact formatted address for copying
  String getCompactAddress() {
    List<String> parts = [];
    
    if (name.isNotEmpty) parts.add(name);
    if (address.isNotEmpty) parts.add(address);
    if (area.isNotEmpty) parts.add('Area: $area');
    if (street.isNotEmpty) parts.add('Street: $street');
    if (building.isNotEmpty) parts.add('Building: $building');
    if (floor.isNotEmpty) parts.add('Floor: $floor');
    if (apartment.isNotEmpty) parts.add('Apartment: $apartment');
    if (landmark.isNotEmpty) parts.add('Landmark: $landmark');
    if (phoneNumber.isNotEmpty) parts.add('Phone: $phoneNumber');
    
    return parts.join(', ');
  }

  /// Returns only the key address fields as a single multiline string.
  /// Fields included: name, area, street, building, floor, apartment, landmark, phone.
  /// This is suitable for copying to the clipboard.
  String getCopyAddressString() {
    final parts = <String>[];
    if (name.isNotEmpty) parts.add('Name: $name');
    if (area.isNotEmpty) parts.add('Area: $area');
    if (street.isNotEmpty) parts.add('Street: $street');
    if (building.isNotEmpty) parts.add('Building: $building');
    if (floor.isNotEmpty) parts.add('Floor: $floor');
    if (apartment.isNotEmpty) parts.add('Apartment: $apartment');
    if (landmark.isNotEmpty) parts.add('Landmark: $landmark');
    if (phoneNumber.isNotEmpty) parts.add('Phone: $phoneNumber');
    return parts.join('\n');
  }

  @override
  String toString() {
    return 'Address(userId: $userId, addressId: $addressId, name: $name, latitude: $latitude, longitude: $longitude, address: $address, phoneNumber: $phoneNumber, area: $area, street: $street, building: $building, floor: $floor, apartment: $apartment, landmark: $landmark)';
  }

  @override
  bool operator ==(covariant Address other) {
    if (identical(this, other)) return true;
  
    return 
      other.userId == userId &&
      other.addressId == addressId &&
      other.name == name &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.address == address &&
      other.phoneNumber == phoneNumber &&
      other.area == area &&
      other.street == street &&
      other.building == building &&
      other.floor == floor &&
      other.apartment == apartment &&
      other.landmark == landmark;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
      addressId.hashCode ^
      name.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      address.hashCode ^
      phoneNumber.hashCode ^
      area.hashCode ^
      street.hashCode ^
      building.hashCode ^
      floor.hashCode ^
      apartment.hashCode ^
      landmark.hashCode;
  }
}
