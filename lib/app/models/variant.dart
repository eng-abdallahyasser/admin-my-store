class Variant {
  String id;
  String name; // Example: "Large", "Small", "Red", "Blue"
  double price;

  Variant({
    required this.id,
    required this.name,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
    );
  }
  Variant copyWith({
  String? id,
  String? name,
  double? price,
}) {
  return Variant(
    id: id ?? this.id,
    name: name ?? this.name,
    price: price ?? this.price,
  );
}
}