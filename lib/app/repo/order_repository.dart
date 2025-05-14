import 'package:admin_my_store/app/models/address.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_my_store/app/models/my_order.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MyOrder>> getOrders({List<String>? statusFilters}) async {
    Query query = _firestore.collection('orders').orderBy('createdAt', descending: true);
    
    if (statusFilters != null && statusFilters.isNotEmpty) {
      query = query.where('status', whereIn: statusFilters);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => MyOrder.fromFirestore(doc)).toList();
  }

  Future<MyOrder> getOrderById(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    return MyOrder.fromFirestore(doc);
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendNotification(String orderId) async {
    // Implement your notification logic here
    // Could use Firebase Cloud Messaging
  }
  static Future<Address> getAddress(String addressId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('addresses')
        .doc(addressId)
        .get();

    if (!doc.exists) {
      throw Exception('Address document not found');
    }

    final data = doc.data();
    if (data == null) {
      throw Exception('Address data is null');
    }

    return Address.fromMap(data); // Assuming you have a fromMap constructor
  } catch (e) {
    // You can log the error here if needed
    // debugPrint('Error getting address: $e');
    rethrow; // Rethrow to let the caller handle it
  }
}
}