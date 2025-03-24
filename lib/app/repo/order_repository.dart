import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_my_store/app/models/order.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addOrder(OrderForDelivary order) async {
    await _firestore.collection('orders').doc(order.orderID).set({
      'userID': order.userID,
      'addressID': order.addressID,
      'cartItems': order.cartItem.map((item) => item.productId).toList(),
    });
  }
}