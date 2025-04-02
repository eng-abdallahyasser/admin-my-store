import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_my_store/app/models/order.dart';

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
}