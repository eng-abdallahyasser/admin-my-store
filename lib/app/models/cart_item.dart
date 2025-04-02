import 'package:admin_my_store/app/models/variant.dart';

class CartItem {
  final String productId;
  final int quantity;
  final String note;
  final double unitPrice;
  final double totalPrice;
  final List<Variant> choosedVariant;

  CartItem({
    required this.productId,
    required this.quantity,
    required this.note,
    required this.unitPrice,
    required this.totalPrice,
    required this.choosedVariant,
  });

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "quantity": quantity,
    "note": note,
    "unitPrice": unitPrice,
    "totalPrice": totalPrice,
    "choosedVariant": choosedVariant.map((variant) => variant.toJson()).toList(),
  };

  factory CartItem.fromJson(cart) {
    return CartItem(
      productId: _parseString(cart["productId"]) ,
      quantity: _parseInt(cart["quantity"]) ,
      note: _parseString(cart["note"]) ,
      unitPrice: _parseDouble(cart["unitPrice"]),
      totalPrice: _parseDouble(cart["totalPrice"]) ,
      choosedVariant: _parseVariants(cart["choosedVariant"]),
    );
  }

  static List<Variant> _parseVariants(dynamic variantsData) {
    try {
      if (variantsData is List) {
        return List<dynamic>.from(variantsData)
            .map<Variant>((v) => Variant.fromJson(v as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error parsing variants: $e');
      return [];
    }
  }

  static String _parseString(dynamic value) {
    if (value == null) return 'Unknown';
    if (value is String) return value;
    return value.toString();
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
