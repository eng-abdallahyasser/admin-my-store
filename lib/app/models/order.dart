import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:admin_my_store/app/models/cart_item.dart';

class OrderForDelivary {
  List<CartItem> cartItem;
  int number;
  String orderID;
  String userID;
  String addressID;
  
  String dateTime;
  OrderForDelivary({
    required this.cartItem,
    this.number=0,
    required this.orderID,
    required this.userID,
    required this.addressID,
    this.dateTime="",
  });

 

  OrderForDelivary copyWith({
    List<CartItem>? cartItem,
    int? number,
    String? orderID,
    String? userID,
    String? addressID,
    String? dateTime,
  }) {
    return OrderForDelivary(
      cartItem: cartItem ?? this.cartItem,
      number: number ?? this.number,
      orderID: orderID ?? this.orderID,
      userID: userID ?? this.userID,
      addressID: addressID ?? this.addressID,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cartItem': cartItem.map((x) => x.toJson()).toList(),
      'number': number,
      'orderID': orderID,
      'userID': userID,
      'addressID': addressID,
      'dateTime': dateTime,
    };
  }

  factory OrderForDelivary.fromMap(Map<String, dynamic> map) {
    return OrderForDelivary(
      cartItem: List<CartItem>.from((map['cartItem'] as List<int>).map<CartItem>((x) => CartItem.fromJson(x as Map<String,dynamic>),),),
      number: map['number'] as int,
      orderID: map['orderID'] as String,
      userID: map['userID'] as String,
      addressID: map['addressID'] as String,
      dateTime: map['dateTime'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderForDelivary.fromJson(String source) => OrderForDelivary.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrderForDelivary(cartItem: $cartItem, number: $number, orderID: $orderID, userID: $userID, addressID: $addressID, dateTime: $dateTime)';
  }

  @override
  bool operator ==(covariant OrderForDelivary other) {
    if (identical(this, other)) return true;
  
    return 
      listEquals(other.cartItem, cartItem) &&
      other.number == number &&
      other.orderID == orderID &&
      other.userID == userID &&
      other.addressID == addressID &&
      other.dateTime == dateTime;
  }

  @override
  int get hashCode {
    return cartItem.hashCode ^
      number.hashCode ^
      orderID.hashCode ^
      userID.hashCode ^
      addressID.hashCode ^
      dateTime.hashCode;
  }
}
