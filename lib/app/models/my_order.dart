import 'dart:convert';
import 'package:admin_my_store/app/models/cart_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MyOrder {
  final String id;
  int? orderNumber;
  final String userId;
  final List<CartItem> items;
  final double total;
  String status;
  final DateTime createdAt;
  DateTime? updatedAt;
  final String paymentStatus;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String shippingAddress;

  MyOrder({
    required this.id,
    this.orderNumber,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.paymentStatus,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.shippingAddress,
  });

  MyOrder copyWith({
    String? id,
    String? userId,
    int? orderNumber,
    List<CartItem>? items,
    double? total,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? paymentStatus,
    String? customerName,
    String? customerId,
    String? customerEmail,
    String? customerPhone,
    String? shippingAddress,
  }) {
    return MyOrder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      shippingAddress: shippingAddress ?? this.shippingAddress,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'items': items.map((x) => x.toJson()).toList(),
      'total': total,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'paymentStatus': paymentStatus,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'shippingAddress': shippingAddress,
    };
  }

  factory MyOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MyOrder(
      id: doc.id,
      orderNumber: data['orderNumber'] as int? ?? -1,
      userId: data['userId'] as String? ?? 'unknown_user',
      items:
          (data['items'] as List<dynamic>? ?? [])
              .map((i) => CartItem.fromJson(i as Map<String, dynamic>))
              .toList(),
      total: (data['total'] as num? ?? 0.0).toDouble(),
      status: data['status'] as String? ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      paymentStatus: data['paymentStatus'] as String? ?? 'unpaid',
      customerName: data['customerName'] as String? ?? 'Unknown Customer',
      customerEmail: data['customerEmail'] as String? ?? 'No Email',
      customerPhone: data['customerPhone'] as String? ?? 'No Phone',
      shippingAddress: data['shippingAddress'] as String? ?? 'No Address',
    );
  }

  factory MyOrder.fromMap(Map<String, dynamic> map) {
    return MyOrder(
      id: map['id'] as String,
      userId: map['userId'] as String,
      orderNumber: map['orderNumber'] as int,
      items: List<CartItem>.from(
        (map['items'] as List<int>).map<CartItem>(
          (x) => CartItem.fromJson(x as Map<String, dynamic>),
        ),
      ),
      total: map['total'] as double,
      status: map['status'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt:
          map['updatedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
              : null,
      paymentStatus: map['paymentStatus'] as String,
      customerName: map['customerName'] as String,
      customerEmail: map['customerEmail'] as String,
      customerPhone: map['customerPhone'] as String,
      shippingAddress: map['shippingAddress'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory MyOrder.fromJson(String source) =>
      MyOrder.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Order(id: $id, userId: $userId,orderNumber: $orderNumber, items: $items, total: $total, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, paymentStatus: $paymentStatus, customerName: $customerName, customerEmail: $customerEmail, customerPhone: $customerPhone, shippingAddress: $shippingAddress)';
  }

  @override
  bool operator ==(covariant MyOrder other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.orderNumber == orderNumber &&
        listEquals(other.items, items) &&
        other.total == total &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.paymentStatus == paymentStatus &&
        other.customerName == customerName &&
        other.customerEmail == customerEmail &&
        other.customerPhone == customerPhone &&
        other.shippingAddress == shippingAddress;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        items.hashCode ^
        total.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        paymentStatus.hashCode ^
        customerName.hashCode ^
        customerEmail.hashCode ^
        customerPhone.hashCode ^
        shippingAddress.hashCode;
  }
}
