import 'product.dart';

class CartItem {
  Product? product;
  String? productId;
  int numOfItem;
  final String note;

  CartItem({
    this.product,
    this.productId,
    required this.numOfItem,
    required this.note,
  });

  Map<String, dynamic> toJson() =>
      {"productId": product!.id, "numberOfItems": numOfItem,"note":note};

  factory CartItem.fromJson(cart) {
    return CartItem(
      product: Product(imagesUrl: [], colors: []),
      productId: cart["productId"],
      numOfItem: cart["numberOfItems"],
      note: cart["note"],
    );
  }
}
