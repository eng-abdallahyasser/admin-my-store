// product_repository.dart
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_my_store/app/models/category.dart';
import 'package:admin_my_store/app/models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Product>> getAllProducts() async {
    try {
      final snapshot =
          await _firestore
              .collection('products')
              // .orderBy('createdAt', descending: true)
              .get();
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      log( e.toString(), name: 'ProductRepository.getAllProducts');
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<String> addProduct(Product product) async {
    try {
      final docRef = await _firestore.collection('products').add({
        ...product.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'added by': _auth.currentUser!.uid,
      });

      await docRef.update({"id": docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduct(String productId, Product product) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        ...product.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  Future<Product> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) throw Exception('Product not found');
      return Product.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Stream<QuerySnapshot> getProductsStream() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateProductStock(String productId, int newQuantity) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'quantity': newQuantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }
}
