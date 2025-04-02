import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_my_store/app/models/order.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MyOrder>> getOrders({List<String>? statusFilters}) async {
    Query query = _firestore.collection('orders');
    
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
  Future<void> addOrder(MyOrder order) async {
    try {
      // Create a reference to the counter document
      DocumentReference counterRef =
          _firestore.collection("counters").doc("orderCounter");

      // Run a transaction to ensure atomicity
      await _firestore.runTransaction((transaction) async {
        // Get the current counter value
        DocumentSnapshot counterSnapshot = await transaction.get(counterRef);

        // Check if the document exists, if not create it with an initial currentNumber of 0
        int currentNumber = 0;
        if (!counterSnapshot.exists) {
          transaction.set(counterRef, {'currentNumber': currentNumber});
        } else {
          currentNumber = (counterSnapshot.data()
                  as Map<String, dynamic>)['currentNumber'] ??
              0;
        }

        // Increment the counter
        int newNumber = currentNumber + 1;

        // Update the order with the new number
        order.orderNumber=newNumber;

        // Create a new document reference for the order
        DocumentReference docRef = _firestore.collection("orders").doc();

        // Add the order to Firestore within the transaction
        transaction.set(docRef, order.toJson());

        // Update the orderID field in the newly created order document
        transaction.update(docRef, {"orderID": docRef.id});

        // Update the counter value in Firestore
        transaction.update(counterRef, {'currentNumber': newNumber});
      });
    } catch (error) {
      log("Failed to add order: $error");
    }
  }

  Future<void> sendNotification(String orderId) async {
    // Implement your notification logic here
    // Could use Firebase Cloud Messaging
  }
}